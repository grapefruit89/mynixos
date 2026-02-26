# 🔒 PROMPT TEIL 3 von 3: Service-Hardening + Traefik Best Practice
## Systemd-Härtung · VPN-Confinement · Traefik-Secrets · Alle Services

---

## KONTEXT FÜR DIE AUSFÜHRENDE KI

Du arbeitest an einem NixOS-Homelab-Repository (Fujitsu Q958, Intel i3-9100, UHD 630).
Das Herzstück ist Traefik als Reverse-Proxy mit Cloudflare DNS-01 Challenge.

**PRIORITÄT:** Traefik ist das kritischste System — es muss immer, zuverlässig und korrekt funktionieren.
Alle anderen Härtungsmaßnahmen sind sekundär.

**Bevor du irgendetwas änderst:**
1. Konsultiere Context7 für aktuelle Dokumentation:
   - Library ID: `/websites/nixos_manual_nixos_unstable`
   - Query: `"systemd service hardening PrivateTmp ProtectSystem NoNewPrivileges"`
   - Query: `"traefik NixOS environmentFiles LoadCredential secrets"`
   - Library ID: `/nixos/nixpkgs`
   - Query: `"jellyfin hardware graphics vaapi intel DynamicUser"`
2. Lies vollständig vor Änderungen:
   - `10-infrastructure/traefik-core.nix`
   - `00-core/secrets.nix`
   - `20-services/media/jellyfin.nix`
   - `20-services/apps/vaultwarden.nix`
   - `20-services/apps/n8n.nix`
   - `20-services/media/sabnzbd.nix`

---

## AUFGABE 1: Traefik — Battle-Tested Best Practice (HÖCHSTE PRIORITÄT)

### Aktueller Stand — Was gut ist ✅

```nix
# traefik-core.nix — bereits korrekt:
environmentFiles = [ config.my.secrets.files.sharedEnv ];
certificatesResolvers.letsencrypt.acme.dnsChallenge.provider = "cloudflare";
entryPoints.websecure.address = ":443";
# Kein HTTP-Entrypoint (Port 80 deaktiviert) ✅
# ACME-Storage in dataDir ✅
# forwardedHeaders.trustedIPs mit Cloudflare-Ranges ✅
```

### Problem 1: Secrets-Scope zu breit

```nix
# AKTUELL: Traefik bekommt ALLE Secrets aus der shared-Datei
environmentFiles = [ config.my.secrets.files.sharedEnv ];
# Enthält: CLOUDFLARE_DNS_API_TOKEN, WG_PRIVADO_PRIVATE_KEY,
#          SONARR_API_KEY, RADARR_API_KEY, PROWLARR_API_KEY, SABNZBD_API_KEY
# Traefik braucht NUR: CLOUDFLARE_DNS_API_TOKEN
```

### Lösung 1A: Separates Traefik-Environment-File (sofort umsetzbar)

```nix
# 00-core/secrets.nix — neue Option ergänzen:
options.my.secrets.files = {
  # ... bestehende Options ...

  # source-id: CFG.secrets.traefikEnv
  traefikEnv = lib.mkOption {
    type = lib.types.str;
    default = "/etc/secrets/traefik.env";
    description = "Traefik-exklusives Environment-File (nur CLOUDFLARE_DNS_API_TOKEN).";
  };
};

# Beispiel-Datei generieren:
config.environment.etc."secrets/traefik.env.example".text = ''
  # Traefik-exklusive Secrets (nur Cloudflare DNS-01)
  # Kopieren nach: /etc/secrets/traefik.env
  # Berechtigungen: root:traefik 640
  CLOUDFLARE_DNS_API_TOKEN=
'';
```

```nix
# 10-infrastructure/traefik-core.nix — EnvironmentFile anpassen:
services.traefik = {
  # source: my.secrets.files.traefikEnv (nur CF-Token)
  # source: my.secrets.files.sharedEnv (für andere Traefik-Plugins falls nötig)
  environmentFiles = [
    config.my.secrets.files.traefikEnv   # ← bevorzugt: nur was Traefik braucht
    # config.my.secrets.files.sharedEnv  # ← Fallback bis traefikEnv existiert
  ];
};
```

**Bootstrap-Schritt für Server:**
```bash
# Einmalig ausführen:
sudo install -d -m 750 -o root -g traefik /etc/secrets/
sudo install -m 640 -o root -g traefik \
  /etc/secrets/traefik.env.example \
  /etc/secrets/traefik.env
sudo nano /etc/secrets/traefik.env
# → CLOUDFLARE_DNS_API_TOKEN=<dein-token>
```

### Lösung 1B: systemd LoadCredential (moderner Ansatz, NixOS 24.05+)

```nix
# Konsultiere Context7 Query: "systemd LoadCredential NixOS ACME secrets"
# Dann implementieren als:

systemd.services.traefik.serviceConfig = {
  LoadCredential = [
    "cloudflare-token:/etc/secrets/cloudflare-token"
  ];
  # In Traefik via ${CREDENTIALS_DIRECTORY}/cloudflare-token verfügbar
};
```

**HINWEIS:** LoadCredential ist eleganter aber erfordert Anpassung in der Traefik-Konfiguration.
Für jetzt ist **Lösung 1A ausreichend und battle-tested**.

### Problem 2: Traefik-Service läuft ohne Systemd-Härtung

Das NixOS-Traefik-Modul setzt schon einige Defaults, aber ergänze explizit:

```nix
# 10-infrastructure/traefik-core.nix — systemd Härtung ergänzen:
systemd.services.traefik.serviceConfig = lib.mkAfter {
  # Traefik braucht Netzwerk → kein PrivateNetwork
  # Traefik schreibt acme.json → ProtectSystem nur partial

  NoNewPrivileges = true;
  PrivateTmp = true;

  # Traefik braucht Port 443 binden → AmbientCapabilities nötig
  AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

  # Dateisystem: nur dataDir beschreibbar
  ProtectSystem = "strict";
  ReadWritePaths = [
    config.services.traefik.dataDir          # acme.json, logs
    "/var/log/traefik"                        # falls accessLog file-basiert
  ];
  ProtectHome = true;

  # Kernel-Schutz
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectControlGroups = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;

  # Netzwerk: Traefik braucht AF_INET + AF_INET6
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
};
```

**⚠️ WICHTIG nach dieser Änderung:**
```bash
sudo nixos-rebuild test
sudo systemctl status traefik
sudo journalctl -u traefik -n 50 --no-pager
# Prüfen: acme.json wird korrekt geschrieben:
ls -la /var/lib/traefik/acme.json
# Prüfen: HTTPS funktioniert:
curl -k https://localhost:443/ -o /dev/null -w "%{http_code}"
```

---

## AUFGABE 2: Vollständige Service-Härtungs-Matrix

### Welche Services brauchen Härtung?

**Analyse aller aktiven Services:**

| Service | DynamicUser | PrivateTmp | ProtectSystem | Status |
|---------|-------------|------------|---------------|--------|
| Traefik | Nein | Nein | Nein | → Aufgabe 1 |
| Jellyfin | Nein (braucht /dev/dri) | Nein | Nein | → Aufgabe 3 |
| Vaultwarden | Nein | Nein | Nein | → Aufgabe 4 |
| n8n | Ja (DynamicUser) | Implizit | Teilweise | → Aufgabe 5 |
| SABnzbd | Nein (feste UID/GID!) | Nein | Nein | → Aufgabe 6 |
| Sonarr/Radarr | Nein | Nein | Nein | → Aufgabe 7 |
| Miniflux | DynamicUser | Implizit | Ja | ✅ Weitgehend OK |
| Paperless | DynamicUser | Implizit | Ja | ✅ Weitgehend OK |
| Audiobookshelf | DynamicUser | Implizit | Ja | ✅ Weitgehend OK |
| AdGuard | DynamicUser | Implizit | Ja | ✅ Weitgehend OK |
| Homepage | Expliziter User | Nein | Nein | → leichte Härtung |

---

## AUFGABE 3: Jellyfin — Hardware-Zugriff + Härtung

### Besonderheit
Jellyfin braucht `/dev/dri/renderD128` für Intel QuickSync (UHD 630).
`PrivateDevices = true` würde QuickSync deaktivieren — das darf NICHT gesetzt werden.

### Konsultiere Context7
```
Library: /nixos/nixpkgs
Query: "jellyfin NixOS hardware graphics DynamicUser device render"
```

### Implementierung

```nix
# 20-services/media/jellyfin.nix — Härtung ergänzen:
config = lib.mkIf config.my.media.jellyfin.enable {
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver    # iHD für UHD 630 (Gen 9.5) — korrekt
    # intel-vaapi-driver  # ENTFERNEN: nur für Gen 8 und älter
    intel-compute-runtime # OpenCL für tone-mapping
  ];

  # LIBVA_DRIVER_NAME explizit setzen — verhindert Driver-Confusion
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  users.users.jellyfin.extraGroups = [ "video" "render" ];

  # source: systemd Härtung für Jellyfin
  # sink: jellyfin.service
  systemd.services.jellyfin.serviceConfig = {
    NoNewPrivileges = true;
    PrivateTmp = true;

    # PrivateDevices = false ist der Default — NICHT setzen
    # Jellyfin braucht /dev/dri/* für Hardware-Transcoding
    # Stattdessen: explizit erlaubte Devices
    DeviceAllow = [
      "/dev/dri rw"           # Intel GPU
      "/dev/dri/renderD128 rw" # Hardware-Render-Node
    ];

    # Dateisystem-Einschränkungen
    ProtectSystem = "strict";
    ReadWritePaths = [
      "/var/lib/jellyfin"   # Jellyfin State
      "/data/media"         # Medienbibliothek (read ist genug, aber jellyfin schreibt cache)
    ];
    ProtectHome = true;

    # Kernel-Schutz (kein Hardware-Einfluss auf diese)
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;

    # Netzwerk: nur localhost und LAN
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
};
```

**Verifikation:**
```bash
sudo systemctl status jellyfin
# Hardware-Transcoding testen: in Jellyfin Dashboard → Transcoding prüfen
vainfo --display drm --device /dev/dri/renderD128
```

---

## AUFGABE 4: Vaultwarden — Härtung für Passwort-Manager

### Besonderheit
Vaultwarden speichert Passwörter — hohe Priorität für Härtung.

```nix
# 20-services/apps/vaultwarden.nix — Härtung ergänzen:
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = config.my.ports.vaultwarden;
      # Explizit: kein Admin-Panel ohne Token
      # ADMIN_TOKEN = ... (aus secrets.env setzen, nicht hier)
    };
  };

  # source: systemd Härtung für Vaultwarden
  # sink: vaultwarden.service (bitwarden_rs)
  systemd.services.vaultwarden.serviceConfig = {
    # Vaultwarden hat keinen DynamicUser — explizite Härtung nötig
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;      # Kein Hardware-Zugriff nötig

    ProtectSystem = "strict";
    ReadWritePaths = [
      "/var/lib/bitwarden_rs"   # Vaultwarden Data-Dir
      "/var/lib/vaultwarden"    # Falls neuere Version anderen Pfad nutzt
    ];
    ProtectHome = true;

    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;

    # Vaultwarden braucht nur TCP für localhost
    RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];

    # Memory-Schutz
    MemoryDenyWriteExecute = true;

    # Syscall-Filter
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    SystemCallArchitectures = "native";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.${domain}`) || Host(`vaultwarden.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.vaultwarden}";
    }];
  };
}
```

---

## AUFGABE 5: n8n — Härtung für Workflow-Automation

### Besonderheit
n8n führt **benutzerdefinierte Workflows** aus — potenziell gefährlich wenn nicht eingeschränkt.
n8n kann externe HTTP-Requests machen, Scripts ausführen und auf Dateisystem zugreifen.

```nix
# 20-services/apps/n8n.nix — Härtung ergänzen:
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
  services.n8n = {
    enable = true;
    environment = {
      N8N_PORT = toString config.my.ports.n8n;
      N8N_HOST = "127.0.0.1";
      # Sicherheits-Einstellungen für n8n:
      N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
      EXECUTIONS_DATA_PRUNE = "true";
      EXECUTIONS_DATA_MAX_AGE = "336";  # 14 Tage
    };
  };

  # source: systemd Härtung für n8n
  # sink: n8n.service
  systemd.services.n8n.serviceConfig = {
    # n8n hat DynamicUser durch NixOS-Modul — aber explizite Ergänzungen:
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;

    ProtectSystem = "strict";
    ReadWritePaths = [
      "/data/state/n8n"   # n8n State-Dir (aus media-stack.nix tmpfiles)
    ];
    ProtectHome = true;

    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;

    # n8n macht externe HTTP-Requests (Webhooks etc.)
    # → AF_INET erlauben, aber kein Raw-Socket
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];

    # Syscall-Filter (vorsichtig — n8n kann Node.js-Subprocesses spawnen)
    SystemCallFilter = [
      "@system-service"
      "@process"      # n8n braucht fork/exec für Subprocesses
      "~@privileged"
    ];
    SystemCallArchitectures = "native";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.n8n = {
      rule = "Host(`n8n.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "n8n";
    };
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.n8n}";
    }];
  };
}
```

---

## AUFGABE 6: SABnzbd — VPN-Confinement Analyse + Härtung

### Aktueller Stand (bereits gut!)

```nix
# 20-services/media/sabnzbd.nix — VPN-Binding bereits korrekt:
systemd.services.sabnzbd = {
  bindsTo = [ "wg-quick-privado.service" ];
  partOf = [ "wg-quick-privado.service" ];
  requires = [ "wg-quick-privado.service" ];
  after = [ "wg-quick-privado.service" ];
  serviceConfig.RestrictNetworkInterfaces = [ "lo" "privado" ];
};
```

`RestrictNetworkInterfaces` ist Kernel-Level — echter Interface-Filter.
Das ist **leak-proof** für normalen Traffic.

### DNS-Leak-Mitigation ergänzen

```nix
# SABnzbd-spezifisches DNS via VPN erzwingen:
systemd.services.sabnzbd.serviceConfig = {
  # ... bestehende VPN-Bindings ...
  RestrictNetworkInterfaces = [ "lo" "privado" ];

  # DNS-Leak mitigation: systemd-resolved bypassen für SABnzbd
  # source-id: CFG.vpn.privado.dns
  Environment = [
    "DNSSERVERS=${lib.concatStringsSep "," config.my.configs.vpn.privado.dns}"
  ];

  # Härtung:
  NoNewPrivileges = true;
  PrivateTmp = true;
  PrivateDevices = true;
  ProtectSystem = "strict";
  ReadWritePaths = [
    "/var/lib/sabnzbd"
    "/data/downloads"         # Download-Verzeichnis
  ];
  ProtectHome = true;
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  RestrictSUIDSGID = true;
};
```

---

## AUFGABE 7: Sonarr/Radarr/Prowlarr — _lib.nix Härtung

### Problem
Die `_lib.nix`-Factory generiert Services ohne Systemd-Härtung.

### Lösung: Härtung in `_lib.nix` einbauen

```nix
# 20-services/media/_lib.nix — im config = lib.mkIf cfg.enable Block ergänzen:
config = lib.mkIf cfg.enable {
  # ... bestehende Konfiguration ...

  # source: systemd Basis-Härtung für alle media-lib Services
  # sink: ${name}.service
  systemd.services.${name}.serviceConfig = {
    NoNewPrivileges = lib.mkDefault true;
    PrivateTmp = lib.mkDefault true;
    PrivateDevices = lib.mkDefault true;
    ProtectSystem = lib.mkDefault "strict";
    ReadWritePaths = lib.mkDefault [ cfg.stateDir "/data/media" "/data/downloads" ];
    ProtectHome = lib.mkDefault true;
    ProtectKernelTunables = lib.mkDefault true;
    ProtectKernelModules = lib.mkDefault true;
    ProtectControlGroups = lib.mkDefault true;
    RestrictRealtime = lib.mkDefault true;
    RestrictSUIDSGID = lib.mkDefault true;
    RestrictAddressFamilies = lib.mkDefault [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
};
```

**Wichtig:** `lib.mkDefault` erlaubt Override in spezifischen Service-Dateien.
Jellyfin überschreibt z.B. `PrivateDevices = false` für Hardware-Zugriff.

---

## AUFGABE 8: Homepage Dashboard — Härtung

```nix
# 10-infrastructure/homepage.nix — serviceConfig ergänzen:
systemd.services.homepage.serviceConfig = lib.mkAfter {
  NoNewPrivileges = true;
  PrivateTmp = true;
  PrivateDevices = true;

  ProtectSystem = "strict";
  ReadWritePaths = [
    homepageConfigDir   # /data/state/homepage
  ];
  ProtectHome = true;

  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;

  # Homepage braucht Netzwerk für Service-Widget-Checks
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
};
```

---

## AUFGABE 9: Nix-Store-Optimierung für Q958

### Hardware-Profil: i3-9100 (4 Cores), kein ECC-RAM, NVMe 500GB

```nix
# 00-core/system.nix — Nix-Einstellungen ergänzen:
nix = {
  settings = {
    # Store-Optimierung: Hardlinks statt Kopien (spart ~30% NVMe-Platz)
    auto-optimise-store = true;

    # Parallele Jobs: 4 Cores, aber 1 für System lassen
    max-jobs = 3;
    cores = 4;

    # Binary Caches (schnellere Builds)
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBw="
    ];

    # Flake-Features (auch ohne Flakes nützlich)
    experimental-features = [ "nix-command" "flakes" ];

    # Kein automatisches Garbage-Collect während Builds
    keep-outputs = true;
    keep-derivations = true;
  };

  # Automatische GC: wöchentlich, 14 Tage Retention
  gc = {
    automatic = true;
    dates = "Sun 03:30";      # Sonntag Nacht — HDDs können schlafen
    options = "--delete-older-than 14d";
  };

  # Store-Optimierung nach GC
  optimise = {
    automatic = true;
    dates = [ "Sun 04:00" ];  # Nach GC
  };
};
```

---

## MASTER-REIHENFOLGE FÜR ALLE DREI TEILE

Die richtige Implementierungsreihenfolge über alle drei Prompt-Teile:

```
WOCHE 1 — Sicherheitskritisch:
├── [T1-A1] traefik.nix broken Import reparieren
├── [T1-A2] server-rules.nix zu Stub degradieren
├── [T1-A3] configuration.nix Duplikate bereinigen
├── [T1-A4] nftables-Migration (TESTE MIT nixos-rebuild test!)
├── [T2-A1] AdGuard IP-Zentralisierung in configs.nix
└── [T3-A1] Traefik separates Environment-File + Systemd-Härtung

WOCHE 2 — Qualitätsverbesserung:
├── [T2-A2] scan-ids.sh Script erstellen und testen
├── [T2-A3] VPN-Config aus wireguard-vpn.nix in configs.nix
├── [T2-A5] Pocket-ID Port zentralisieren
├── [T3-A3] Jellyfin Härtung + intel-vaapi-driver entfernen
└── [T3-A4] Vaultwarden Härtung

WOCHE 3 — Vollständige Härtung:
├── [T3-A5] n8n Härtung
├── [T3-A6] SABnzbd DNS-Leak Mitigation
├── [T3-A7] _lib.nix Basis-Härtung für alle Media-Services
├── [T3-A8] Homepage Härtung
└── [T3-A9] Nix-Store-Optimierung

WOCHE 4 — Assertions aktivieren:
└── [T1-A2] security-assertions.nix einkommentieren wenn alles stabil
```

---

## VOLLSTÄNDIGE TEST-CHECKLISTE NACH ALLEN ÄNDERUNGEN

```bash
#!/usr/bin/env bash
# scripts/post-change-verify.sh

echo "=== TRAEFIK ==="
curl -sk https://localhost:443/ -o /dev/null -w "HTTP: %{http_code}\n"
sudo systemctl is-active traefik && echo "✅ traefik aktiv" || echo "❌ traefik down"
ls -la /var/lib/traefik/acme.json && echo "✅ acme.json vorhanden" || echo "❌ acme.json fehlt"

echo "=== SSH ==="
ssh -p 53844 -o BatchMode=yes -o ConnectTimeout=5 moritz@localhost echo "✅ SSH OK" 2>/dev/null \
  || echo "⚠️ SSH nicht via Key erreichbar (ok wenn kein Key konfiguriert)"

echo "=== FIREWALL ==="
sudo nft list ruleset | grep -q "tcp dport 53844" && echo "✅ SSH-Port in nftables" || echo "❌ SSH-Port fehlt"
sudo nft list ruleset | grep -q "tcp dport 443" && echo "✅ HTTPS-Port in nftables" || echo "❌ HTTPS-Port fehlt"

echo "=== SERVICES ==="
for svc in sshd tailscaled traefik fail2ban; do
  systemctl is-active "$svc" >/dev/null && echo "✅ $svc" || echo "❌ $svc"
done

echo "=== DNS ==="
dig @127.0.0.1 nixos.org +short | head -1 && echo "✅ DNS via AdGuard" || echo "❌ DNS failed"

echo "=== VPN ==="
sudo wg show privado 2>/dev/null && echo "✅ WireGuard privado aktiv" || echo "❌ WireGuard down"

echo "=== MEDIA ==="
for svc in jellyfin sonarr radarr sabnzbd; do
  systemctl is-active "$svc" >/dev/null 2>&1 && echo "✅ $svc" || echo "⚠️ $svc nicht aktiv"
done

echo "=== NFTABLES ==="
sudo nft list ruleset | wc -l | xargs echo "nftables Regelzeilen:"

echo "=== DONE ==="
```

---

*Ende der drei-teiligen Prompt-Reihe.*
*Reihenfolge: TEIL 1 (Struktur) → TEIL 2 (Network/IDs) → TEIL 3 (Hardening)*
*Nach jedem Teil: `nixos-rebuild test` → manuell testen → `nixos-rebuild switch`*
