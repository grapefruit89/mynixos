# 🏗️ Universal NixOS Flake Migration Guide
## Vollständige Systemarchitektur nach nixarr-Prinzip

> **Ziel:** Jeder Dienst — ob arr-Stack, Home Assistant oder Paperless — wird als eigenständiges, wiederverwendbares NixOS-Modul unter `myServices.<name>` gekapselt. Die Architektur ist strikt nach [nixarr](https://github.com/jshier/nixarr) modelliert: Implementierung und Konfiguration sind niemals vermischt.

---

## Teil 1: Globale Verzeichnisstruktur

```
my-nixos-config/
│
├── flake.nix                          # Zentraler Einstiegspunkt
├── flake.lock                         # Gepinnte Abhängigkeiten (auto-generiert)
│
├── lib/
│   └── default.nix                    # Eigene Hilfsfunktionen (mkService, etc.)
│
├── modules/
│   ├── default.nix                    # Sammelt alle Module dynamisch
│   │
│   ├── global/
│   │   ├── options.nix                # Globale Optionen (VPN, Proxy, Domain)
│   │   ├── networking.nix             # Zentrales Firewall-Management
│   │   └── secrets.nix                # Globale Secret-Strategie (sops/agenix)
│   │
│   └── services/
│       ├── arr/
│       │   ├── radarr.nix             # Radarr (Film-Downloader)
│       │   ├── sonarr.nix             # Sonarr (Serien-Downloader)
│       │   ├── prowlarr.nix           # Prowlarr (Indexer)
│       │   └── jellyfin.nix           # Jellyfin (Media-Server)
│       │
│       ├── documents/
│       │   └── paperless.nix          # Paperless-ngx (aus Phase 1)
│       │
│       ├── home/
│       │   ├── home-assistant.nix     # Home Assistant
│       │   └── vaultwarden.nix        # Vaultwarden (Bitwarden-Server)
│       │
│       └── infra/
│           ├── nginx.nix              # Reverse-Proxy mit automatischen vHosts
│           ├── backup.nix             # Globales Backup-Modul
│           └── monitoring.nix         # Prometheus + Grafana
│
├── hosts/
│   ├── media-server/
│   │   ├── default.nix               # Nur Werte, keine Implementierung
│   │   └── hardware-configuration.nix
│   │
│   ├── home-server/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   │
│   └── paperless-box/
│       ├── default.nix               # Aus dem vorherigen Schlachtplan
│       └── hardware-configuration.nix
│
└── secrets/
    ├── secrets.yaml                   # sops-nix: verschlüsselte Secrets
    └── .sops.yaml                     # sops-Konfiguration (GPG/age-Keys)
```

---

## Teil 2: Das Fundament — Globale Optionen & Master-Toggles

### `modules/global/options.nix` — Der "Master-Switch"

Nach nixarr-Prinzip existiert ein globaler Namespace, der alle Module beeinflusst. Ein VPN-Toggle in `myServices.settings.vpn` kann automatisch in jedem Dienst-Modul ausgewertet werden.

```nix
# modules/global/options.nix
{ lib, ... }:

with lib;

{
  options.myServices = {

    #########################################################################
    # Globale Einstellungen — beeinflussen alle Module
    #########################################################################
    settings = {

      domain = mkOption {
        type = types.str;
        default = "home.arpa";
        description = ''
          Basis-Domain für alle internen Dienste.
          Wird von nginx.nix für vHost-Generierung verwendet.
          Beispiel: "example.com" → radarr.example.com
        '';
      };

      # Master-Toggle: VPN — nach nixarr-Vorbild
      vpn = {
        enable = mkEnableOption ''
          Globales VPN für alle Dienste, die `useVpn = true` setzen.
          Alle betroffenen Dienste binden nur an das VPN-Interface.
        '';

        interface = mkOption {
          type = types.str;
          default = "wg0";
          description = "WireGuard-Interface-Name des VPN-Tunnels";
        };

        bindAddress = mkOption {
          type = types.str;
          default = "10.0.0.1";
          description = "IP-Adresse des VPN-Interfaces (für Dienst-Binding)";
        };

        configFile = mkOption {
          type = types.path;
          description = "Pfad zur WireGuard-Konfigurationsdatei (Secret!)";
        };
      };

      # Master-Toggle: Reverse Proxy
      reverseProxy = {
        enable = mkEnableOption "Automatische nginx vHost-Generierung für alle Dienste";

        ssl = mkOption {
          type = types.bool;
          default = false;
          description = "HTTPS via Let's Encrypt (benötigt öffentliche Domain)";
        };
      };

      # Backup-Ziel für alle Dienste
      backupDestination = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Globales Backup-Zielverzeichnis.
          Wenn gesetzt, registrieren sich alle Dienste automatisch.
          Null = kein automatisches Backup.
        '';
      };
    };

  };
}
```

### `lib/default.nix` — Eigene Hilfsfunktionen

```nix
# lib/default.nix
{ lib }:

{
  # mkService: Erstellt ein standardisiertes Modul-Gerüst
  # Reduziert Boilerplate in jedem Service-Modul
  mkServiceOption = { name, defaultPort, description }: {
    enable = lib.mkEnableOption description;

    port = lib.mkOption {
      type = lib.types.port;
      default = defaultPort;
      description = "HTTP-Port für ${name}";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Port ${toString defaultPort} in der Firewall öffnen";
    };

    useVpn = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        ${name} an das VPN-Interface binden.
        Erfordert myServices.settings.vpn.enable = true.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${lib.strings.toLower name}";
      description = "Datenpfad für ${name}";
    };
  };
}
```

---

## Teil 3: Das Modul-Blueprint — Radarr als Gold-Standard

Dieses Modul demonstriert **alle** Architekturprinzipien: Master-Toggle-Integration, automatisches Firewall-Management, User/Group-Verwaltung, nginx-Registrierung und Secret-Handling.

```nix
# modules/services/arr/radarr.nix
{ config, lib, pkgs, ... }:

with lib;

let
  # Lokaler Alias für sauberen Code
  cfg = config.myServices.radarr;

  # Globale Einstellungen aus dem Master-Namespace
  globalCfg = config.myServices.settings;

  # Hilfsfunktion: Bind-Adresse abhängig von VPN-Status
  bindAddress =
    if cfg.useVpn && globalCfg.vpn.enable
    then globalCfg.vpn.bindAddress
    else "127.0.0.1";

in
{
  ###########################################################################
  # OPTIONEN — Öffentliche Schnittstelle dieses Moduls
  ###########################################################################
  options.myServices.radarr = {

    enable = mkEnableOption "Radarr Film-Downloader";

    port = mkOption {
      type = types.port;
      # mkDefault: Kann auf Host-Ebene ohne mkForce überschrieben werden
      default = mkDefault 7878;
      description = "HTTP-Port für Radarr";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/radarr";
      description = "Radarr Datenpfad (Datenbank, Konfiguration)";
    };

    mediaDir = mkOption {
      type = types.str;
      default = "/mnt/media/filme";
      description = "Verzeichnis der Filmbibliothek";
    };

    downloadDir = mkOption {
      type = types.str;
      default = "/mnt/downloads";
      description = "Download-Verzeichnis (Qbittorrent/NZBGet Output)";
    };

    # VPN-Integration — greift auf globalen Master-Toggle zurück
    useVpn = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Radarr an das VPN-Interface binden.
        Nur wirksam wenn myServices.settings.vpn.enable = true.
        Verhindert, dass Radarr über die normale IP erreichbar ist.
      '';
    };

    # Firewall — bewusst standardmäßig geschlossen
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Radarr-Port in der Firewall öffnen.
        Im Normalfall nicht nötig, da nginx als Reverse Proxy fungiert.
      '';
    };

    # Nginx-Integration: automatischer vHost
    reverseProxy = {
      enable = mkOption {
        type = types.bool;
        # mkDefault: Erbt globale Einstellung, kann aber lokal überschrieben werden
        default = mkDefault false;
        description = "Radarr über nginx unter radarr.<domain> verfügbar machen";
      };

      subdomain = mkOption {
        type = types.str;
        default = "radarr";
        description = "Subdomain für den nginx vHost";
      };
    };

    # User/Group — sauber getrennt, nicht auf den nixpkgs-Default angewiesen
    user = mkOption {
      type = types.str;
      default = "radarr";
      description = "Systembenutzer für Radarr";
    };

    group = mkOption {
      type = types.str;
      default = "media";
      description = ''
        Gruppe für Radarr. "media" ist die geteilte Gruppe für alle arr-Dienste.
        Stellt sicher, dass Radarr, Sonarr etc. auf dieselben Verzeichnisse zugreifen können.
      '';
    };

    # Secret-Handling
    apiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Pfad zur Datei mit dem Radarr API-Key.
        Wird für die Kommunikation mit Prowlarr/Overseerr verwendet.
        Null = API-Key wird von Radarr beim ersten Start generiert.
      '';
    };

  };

  ###########################################################################
  # IMPLEMENTIERUNG — Nur aktiv wenn enable = true
  ###########################################################################
  config = mkIf cfg.enable {

    # Assertions: Frühzeitige Fehlerprüfung
    assertions = [
      {
        assertion = !(cfg.useVpn && !globalCfg.vpn.enable);
        message = ''
          myServices.radarr.useVpn = true, aber
          myServices.settings.vpn.enable = false.
          Das VPN muss global aktiviert sein, bevor Dienste es nutzen können.
        '';
      }
      {
        assertion = !(cfg.reverseProxy.enable && !globalCfg.reverseProxy.enable);
        message = ''
          myServices.radarr.reverseProxy.enable = true, aber
          myServices.settings.reverseProxy.enable = false.
          Der globale Reverse-Proxy muss zuerst aktiviert werden.
        '';
      }
    ];

    # Systembenutzer und -gruppe
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      description = "Radarr Systembenutzer";
    };

    users.groups.${cfg.group} = {};

    # Verzeichnisse anlegen mit korrekten Berechtigungen
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}  0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.mediaDir} 0775 ${cfg.user} ${cfg.group} -"
      "d ${cfg.downloadDir} 0775 ${cfg.user} ${cfg.group} -"
    ];

    # Radarr-Dienst
    services.radarr = {
      enable = true;
      dataDir = cfg.dataDir;
      user = cfg.user;
      group = cfg.group;

      # Bind-Adresse: VPN-Interface oder localhost
      # mkForce stellt sicher, dass Host-Konfiguration dies nicht versehentlich überschreibt
      openFirewall = mkForce false; # Wir verwalten die Firewall selbst!
    };

    # Systemd-Override für Bind-Adresse und API-Key-Injection
    systemd.services.radarr = {
      environment = {
        RADARR__SERVER__BINDADDRESS = bindAddress;
        RADARR__SERVER__PORT = toString cfg.port;
      } // optionalAttrs (cfg.apiKeyFile != null) {
        # API-Key aus Datei lesen und als Umgebungsvariable setzen
        RADARR__AUTH__APIKEY = ""; # Wird durch EnvironmentFile überschrieben
      };

      serviceConfig = mkMerge [
        {
          # Sicherheitshärtung
          PrivateTmp = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ cfg.dataDir cfg.mediaDir cfg.downloadDir ];
          NoNewPrivileges = true;
        }
        (mkIf (cfg.apiKeyFile != null) {
          EnvironmentFile = cfg.apiKeyFile;
        })
      ];
    };

    # Firewall — nur öffnen wenn explizit angefordert
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    # Nginx vHost — automatisch registrieren wenn reverseProxy aktiv
    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${cfg.reverseProxy.subdomain}.${globalCfg.domain}" = {
        forceSSL = globalCfg.reverseProxy.ssl;
        enableACME = globalCfg.reverseProxy.ssl;

        locations."/" = {
          proxyPass = "http://${bindAddress}:${toString cfg.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };

    # Backup-Registrierung — automatisch wenn globales Backup aktiv
    systemd.services.radarr-backup = mkIf (globalCfg.backupDestination != null) {
      description = "Radarr Konfigurationsbackup";
      after = [ "radarr.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "radarr-backup" ''
          set -euo pipefail
          DEST="${globalCfg.backupDestination}/radarr/$(date +%Y-%m-%d)"
          mkdir -p "$DEST"
          cp -a ${cfg.dataDir}/. "$DEST/"
          echo "Radarr Backup abgeschlossen: $DEST"
        '';
      };
    };

    systemd.timers.radarr-backup = mkIf (globalCfg.backupDestination != null) {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
    };

  };
}
```

---

## Teil 4: Module dynamisch laden (`modules/default.nix`)

```nix
# modules/default.nix
# Importiert alle Module automatisch — kein manuelles Hinzufügen nötig
{ lib, ... }:

{
  imports = [
    # Globale Optionen zuerst laden (stellen den myServices.settings-Namespace bereit)
    ./global/options.nix
    ./global/networking.nix
    ./global/secrets.nix

    # arr-Stack
    ./services/arr/radarr.nix
    ./services/arr/sonarr.nix
    ./services/arr/prowlarr.nix
    ./services/arr/jellyfin.nix

    # Dokumente
    ./services/documents/paperless.nix

    # Home-Automatisierung
    ./services/home/home-assistant.nix
    ./services/home/vaultwarden.nix

    # Infrastruktur
    ./services/infra/nginx.nix
    ./services/infra/backup.nix
    ./services/infra/monitoring.nix
  ];
}
```

### `flake.nix` — Dynamisches Multi-Host-Management

```nix
# flake.nix
{
  description = "Modulare NixOS-Konfiguration nach nixarr-Prinzip";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Secret-Management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Wichtig: Verhindert Nixpkgs-Duplikate!
    };

    # Home Manager (optional)
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    # Hilfsfunktion: Erstellt eine NixOS-Konfiguration für einen Host
    # Reduziert Boilerplate bei vielen Hosts erheblich
    mkHost = { hostname, extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      # inputs weiterreichen, damit Module darauf zugreifen können
      specialArgs = { inherit inputs; };
      modules = [
        # Alle eigenen Module laden
        ./modules
        # sops-nix für Secret-Management
        sops-nix.nixosModules.sops
        # Host-spezifische Konfiguration
        ./hosts/${hostname}/default.nix
      ] ++ extraModules;
    };

  in
  {
    nixosConfigurations = {
      media-server  = mkHost { hostname = "media-server"; };
      home-server   = mkHost { hostname = "home-server"; };
      paperless-box = mkHost { hostname = "paperless-box"; };
    };
  };
}
```

---

## Teil 5: Host-Konfiguration — Nur Werte, keine Logik

```nix
# hosts/media-server/default.nix
{ config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11";
  networking.hostName = "media-server";
  time.timeZone = "Europe/Berlin";

  # sops: Schlüssel für diesen Host
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  #################################################################
  # GLOBALE EINSTELLUNGEN — beeinflussen alle aktivierten Module
  #################################################################
  myServices.settings = {
    domain = "media.home.arpa";
    backupDestination = "/mnt/nas/backups";

    # VPN für den gesamten arr-Stack aktivieren
    vpn = {
      enable = true;
      interface = "wg0";
      bindAddress = "10.8.0.1";
      configFile = config.sops.secrets.wireguard-config.path;
    };

    reverseProxy = {
      enable = true;
      ssl = false; # Internes Netz, kein Let's Encrypt
    };
  };

  #################################################################
  # DIENSTE AKTIVIEREN — saubere Deklaration, null Implementierung
  #################################################################

  myServices.radarr = {
    enable = true;
    mediaDir = "/mnt/media/filme";
    downloadDir = "/mnt/downloads/fertig";
    useVpn = true;                   # Über VPN binden
    reverseProxy.enable = true;      # nginx vHost anlegen
    apiKeyFile = config.sops.secrets.radarr-api-key.path;
  };

  myServices.sonarr = {
    enable = true;
    mediaDir = "/mnt/media/serien";
    downloadDir = "/mnt/downloads/fertig";
    useVpn = true;
    reverseProxy.enable = true;
  };

  myServices.jellyfin = {
    enable = true;
    mediaDir = "/mnt/media";
    reverseProxy.enable = true;
    # Jellyfin braucht kein VPN — direkt zugänglich
    openFirewall = false;
  };

  # Sops-Secrets deklarieren
  sops.secrets = {
    wireguard-config = { owner = "root"; };
    radarr-api-key   = { owner = "radarr"; };
    sonarr-api-key   = { owner = "sonarr"; };
  };
}
```

---

## Teil 6: Secret-Strategie mit sops-nix

### Einmaliges Setup

```bash
# 1. age-Schlüsselpaar für diesen Host generieren
mkdir -p /var/lib/sops-nix
age-keygen -o /var/lib/sops-nix/key.txt

# Öffentlichen Schlüssel anzeigen (wird in .sops.yaml eingetragen)
age-keygen -y /var/lib/sops-nix/key.txt

# 2. Eigenen age-Schlüssel für den Administrator
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

```yaml
# secrets/.sops.yaml
keys:
  # Administrator-Key (für Bearbeitung)
  - &admin age1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqs...
  # Host-Keys (für Entschlüsselung zur Laufzeit)
  - &media-server  age1abc123...
  - &home-server   age1def456...
  - &paperless-box age1ghi789...

creation_rules:
  - path_regex: secrets/secrets.yaml$
    key_groups:
      - age:
        - *admin
        - *media-server
        - *home-server
        - *paperless-box
```

```bash
# 3. Secrets verschlüsselt in secrets.yaml schreiben
sops secrets/secrets.yaml
```

```yaml
# secrets/secrets.yaml (verschlüsselt gespeichert, Klartext nur zur Illustration)
wireguard-config: |
    [Interface]
    PrivateKey = ...
    ...
radarr-api-key: "RADARR__AUTH__APIKEY=abc123def456..."
sonarr-api-key: "SONARR__AUTH__APIKEY=xyz789..."
paperless-admin-password: "mein-sicheres-passwort"
```

---

## Teil 7: Schlachtplan — Migrationsleitfaden (Schritt für Schritt)

### Vorbereitung

```bash
# Repository-Grundstruktur anlegen
mkdir -p my-nixos-config/{lib,modules/{global,services/{arr,documents,home,infra}},hosts,secrets}
cd my-nixos-config
git init

# flake.nix anlegen und Flake-Lock initialisieren
# (Inhalte aus Teil 4 übernehmen)
nix flake update
```

### Schritt 1: Bestehende Konfiguration inventarisieren

```bash
# Alle aktuell aktivierten Dienste auflisten
nixos-option services | grep -E "enable = true"

# Alle manuell geöffneten Firewall-Ports finden
grep -r "allowedTCPPorts\|allowedUDPPorts" /etc/nixos/
```

Erstelle eine Migrationsliste:

| Dienst | Aktueller Port | Firewall offen? | Secret vorhanden? | Priorität |
|---|---|---|---|---|
| Radarr | 7878 | Ja | Nein | Hoch |
| Sonarr | 8989 | Ja | Nein | Hoch |
| Paperless | 28981 | Nein | Passwort | Hoch |
| Home Assistant | 8123 | Ja | Nein | Mittel |

### Schritt 2: Globale Optionen zuerst definieren

Nie mit einem Dienst-Modul beginnen. Immer zuerst `modules/global/options.nix` anlegen — dieser Namespace muss existieren, bevor andere Module ihn referenzieren.

```bash
# Reihenfolge einhalten:
# 1. modules/global/options.nix  ← Master-Namespace
# 2. modules/default.nix         ← Sammler
# 3. flake.nix                   ← Orchestrierung
# 4. Dienst-Module               ← Einer nach dem anderen
```

### Schritt 3: Dienste portieren — einer nach dem anderen

Für jeden Dienst in der Migrationsliste:

```bash
# Schritt A: Modul anlegen (Vorlage aus Teil 3 verwenden)
cp modules/services/arr/radarr.nix modules/services/home/home-assistant.nix
# Namespace, Port, Optionen anpassen

# Schritt B: In modules/default.nix importieren
echo './services/home/home-assistant.nix' >> modules/default.nix

# Schritt C: Host-Konfiguration aktualisieren
# In hosts/<name>/default.nix: myServices.home-assistant.enable = true;

# Schritt D: Syntaxprüfung
nix flake check

# Schritt E: Trockenlauf
sudo nixos-rebuild dry-activate --flake .#<hostname>

# Schritt F: Diff prüfen — was ändert sich?
sudo nixos-rebuild build --flake .#<hostname>
nvd diff /run/current-system result/

# Schritt G: Aktivieren
sudo nixos-rebuild switch --flake .#<hostname>

# Schritt H: Dienst verifizieren
systemctl status home-assistant
journalctl -u home-assistant -n 50
```

### Schritt 4: Secrets migrieren

```bash
# Für jeden Dienst mit Secrets:

# A: Secret in secrets.yaml eintragen (sops öffnet Editor)
sops secrets/secrets.yaml

# B: In flake.nix/host-config deklarieren
# sops.secrets.mein-secret = { owner = "dienst-user"; };

# C: Im Modul referenzieren
# passwordFile = config.sops.secrets.mein-secret.path;

# D: Alten Klartext-Eintrag aus configuration.nix entfernen
# E: Neuaufbau und Test
sudo nixos-rebuild switch --flake .#<hostname>
```

### Schritt 5: Altes `configuration.nix` bereinigen

Erst wenn **alle** Dienste migriert und verifiziert sind:

```bash
# Backup der alten Konfiguration
cp /etc/nixos/configuration.nix ~/configuration.nix.backup

# Veraltete Einträge schrittweise entfernen
# Reihenfolge: Dienste → Firewall-Regeln → User/Groups → Packages

# Nach jedem Entfernen: Rebuild + Test
sudo nixos-rebuild switch --flake .#<hostname>
```

### Schritt 6: Flake-Lock-Wartung

```bash
# Alle Inputs aktualisieren (wöchentlich oder vor Upgrades)
nix flake update

# Nur einen einzelnen Input aktualisieren (z.B. nur nixpkgs)
nix flake lock --update-input nixpkgs

# Diff der Änderungen im Lock-File prüfen (IMMER vor dem Commit!)
git diff flake.lock

# Lock-File committen — niemals in .gitignore!
git add flake.lock && git commit -m "chore: update nixpkgs to 2024-xx-xx"
```

---

## Teil 8: Best Practices & Fallstricke

### `lib.mkDefault` vs. `lib.mkForce`

```nix
# mkDefault: Setzt einen Standardwert, der auf Host-Ebene überschreibbar ist
port = lib.mkDefault 7878;  # Host kann einfach `port = 9999;` schreiben

# mkForce: Erzwingt einen Wert, der NICHT überschrieben werden kann
# Einsatz z.B. für Sicherheitskritisches:
openFirewall = lib.mkForce false;  # Kein Host kann dies auf true setzen
NoNewPrivileges = lib.mkForce true;
```

**Regel:** `mkDefault` in Modul-Optionsdefaults. `mkForce` ausschließlich in Sicherheits-/Implementierungsdetails, die nie von außen überschrieben werden dürfen.

### Cross-Modul-Abhängigkeiten

```nix
# Falsch: Direkte Abhängigkeit zwischen Modulen
config = mkIf config.myServices.sonarr.enable { ... };  # Zirkulär!

# Richtig: Über globale Optionen kommunizieren
# sonarr.nix liest config.myServices.settings.vpn.enable
# Niemals direkt config.myServices.radarr.* lesen!
```

### Gemeinsame Gruppe für den arr-Stack

```nix
# modules/global/networking.nix
users.groups.media = {};  # Einmalig definiert, alle arr-Dienste nutzen sie

# In jedem arr-Modul:
users.users.${cfg.user} = {
  group = "media";  # Geteilte Gruppe statt eigenem Group-Namespace
  extraGroups = [ "media" ];
};
```

### Flake-Lock-Disziplin

```bash
# flake.lock IMMER committen
# flake.lock NIEMALS in .gitignore eintragen
# Updates IMMER als eigenen Commit mit Begründung:
git commit -m "chore: bump nixpkgs to 24.11 stable (security fixes)"

# Produktiv: Staging-Host zuerst updaten, dann Produktion
sudo nixos-rebuild switch --flake .#staging
# Nach Verifikation:
sudo nixos-rebuild switch --flake .#production
```

### Assertion-First-Entwicklung

Jedes Modul sollte frühzeitige Fehler mit `assertions` abfangen — bevor systemd oder Nix selbst mit kryptischen Fehlern abstürzt:

```nix
assertions = [
  {
    assertion = cfg.enable -> (cfg.adminPasswordFile != null);
    message = "myServices.vaultwarden: adminPasswordFile muss gesetzt sein!";
  }
  {
    assertion = !(cfg.useVpn && !config.myServices.settings.vpn.enable);
    message = "VPN-Integration angefordert, aber vpn.enable ist false.";
  }
];
```

---

## Zusammenfassung: Die Goldenen Regeln

```
1. KEIN KLARTEXT IN NIX-DATEIEN     → Alle Secrets via sops-nix/agenix
2. IMPLEMENTIERUNG ≠ KONFIGURATION  → Module definieren WAS, Hosts definieren WIE
3. mkForce FÜR SICHERHEIT           → Sicherheitskritische Optionen niemals überschreibbar
4. EINE GRUPPE FÜR VERWANDTE DIENSTE → arr-Stack teilt "media"-Gruppe
5. ASSERTIONS ZUERST                → Fehler früh abfangen, nicht zur Laufzeit
6. FLAKE.LOCK COMMITTEN             → Reproduzierbarkeit ist keine Option, sie ist Pflicht
7. EIN DIENST PRO COMMIT            → Atomare Migrationsschritte, einfaches Rollback
8. DRY-ACTIVATE VOR SWITCH          → Niemals blind deployen
```

**Endergebnis:** Eine Infrastruktur, bei der das Hinzufügen eines neuen Dienstes bedeutet: Modul kopieren, Namespace anpassen, in `modules/default.nix` importieren, in der Host-Konfiguration mit einer Zeile aktivieren — fertig.
