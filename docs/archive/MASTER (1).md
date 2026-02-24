# NixOS Q958 Homeserver – Master Dokument
**Stand: Februar 2026 | Repo: https://github.com/grapefruit89/mynixos | Domain: m7c5.de**

> **Dieses Dokument ist die einzige Source of Truth.**
> Alle älteren Planungsdokumente (NIXOS_BRIEFING.md, NIXOS_MASTER_BRIEFING.md, q958-nixos-setup.md) sind hiermit obsolet.
> Als erstes in jeden neuen Chat hochladen.

---

## 1. Hardware & System

| Komponente   | Detail                                              |
|--------------|-----------------------------------------------------|
| Gerät        | Fujitsu Q958                                        |
| CPU          | Intel Core i3-9100                                  |
| RAM          | 16 GB                                               |
| iGPU         | Intel UHD 630 – QuickSync H.264/H.265/HEVC         |
| OS-Disk      | Samsung NVMe ~477 GB (`/`)                          |
| Daten-Disk   | Apacer NVMe ~250 GB (`/downloads`, Download-Cache)  |
| HDD 1        | Seagate ~298 GB → `/storage/hdd1` (Filme)           |
| HDD 2        | Hitachi ~500 GB → `/storage/hdd2` (Serien)          |
| HDD 3        | WD ~500 GB → `/storage/hdd3` (Bücher/Hörbücher)    |
| Hostname     | `q958`                                              |
| Benutzer     | `moritz`                                            |
| SSH-Key      | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX moritz@nobara` |
| IP           | `192.168.2.250` (DHCP-Reservierung im Router)       |
| SSH-Port     | **22** (EISERNES GESETZ – nicht ändern!)            |
| Betriebssystem | NixOS **24.11** (nixos-24.11 branch), Flakes      |

> ⚠️ **Versionsabweichung:** Die älteren Planungsdokumente sprechen von NixOS 25.11/Unstable.
> Die tatsächliche `flake.nix` und `system.stateVersion` zeigen **24.11**. Das ist die gültige Version.

---

## 2. Ist-Zustand (direkt aus dem Code – Stand Repo Februar 2026)

| Komponente | Status | Details |
|---|---|---|
| NixOS 24.11, Flakes | ✅ läuft | `system.stateVersion = "24.11"` |
| GUI (XFCE/lightdm) | ✅ entfernt | Headless-Server |
| SSH Port 22, Key-only | ✅ aktiv | `PasswordAuthentication = false` |
| SSH-Key moritz@nobara | ✅ hinterlegt | In `hosts/common/core/users.nix` |
| sudo ohne Passwort | ✅ aktiv | `wheelNeedsPassword = false` |
| fail2ban | ✅ aktiv | 5 Versuche → gesperrt |
| OOM-Schutz sshd (-1000) | ✅ aktiv | In `hosts/common/core/ssh.nix` |
| OOM-Schutz traefik (-900) | ✅ aktiv | In `modules/00-system/nix-settings.nix` |
| Kernel Hardening | ✅ aktiv | `protectKernelImage`, tcp_syncookies |
| system.autoUpgrade | ✅ aktiv | Nur Security-Patches, kein auto-reboot |
| Tailscale | ✅ aktiv | Registriert und läuft |
| Traefik v3 | ✅ aktiv | Port 80/443 offen, startet |
| Swap 4 GB | ✅ aktiv | `/var/lib/swapfile` – für Build-intensive Tasks |
| Nix GC (weekly, 7d) | ✅ aktiv | Automatisch |
| Jellyfin | ✅ **aktiviert** | inkl. Intel QuickSync konfiguriert |
| Audiobookshelf | ✅ **aktiviert** | Port 8000 intern |
| hosts/common/core/ | ✅ vorhanden | users.nix, ssh.nix, firewall.nix |
| Feste IP 192.168.2.250 | ✅ | DHCP-Reservierung im Router |
| Age-Key Konvertierung | ✅ manuell erledigt | `/var/lib/sops-nix/key.txt` liegt auf Server |
| secrets.sops.yaml | ✅ verschlüsselt im Repo | Secrets eingetragen |
| **sops-nix in flake.nix** | ❌ **FEHLT** | Nicht als Input deklariert! |
| **Cloudflare ACME** | ❌ **deaktiviert** | `provider = "cloudflare"` auskommentiert |
| **ACME Wildcard-Zertifikat** | ❌ funktioniert nicht | Hängt an den zwei Punkten oben |
| sops-Block in traefik.nix | ❌ auskommentiert | CF-Token wird nicht geladen |
| HDDs angeschlossen | ⏸ ausstehend | storage.nix ist Dummy |
| DNS-Cutover m7c5.de→Q958 | ⏸ ganz am Ende | Letzter Schritt |

---

## 3. Repo-Struktur (tatsächlich vorhanden)

```
mynixos/                            ← Lokal: ~/nix-config
├── flake.nix                       ✅ inputs: nixpkgs(24.11), disko, vpn-confinement
├── flake.lock
├── .sops.yaml                      ✅ Age Public Key hinterlegt
├── secrets.sops.yaml               ✅ Verschlüsselt, public-safe
├── .gitignore
├── README.md
├── privado_wg_temp.conf            🚨 SICHERHEITSPROBLEM! Plaintext-Key im Repo!
│
├── hosts/
│   ├── q958/
│   │   ├── default.nix             ✅ importiert common/core + aktive Module
│   │   └── hardware-configuration.nix
│   └── common/
│       └── core/                   ✅ vorhanden (war im Plan als fehlend markiert!)
│           ├── default.nix
│           ├── users.nix
│           ├── ssh.nix
│           └── firewall.nix
│
└── modules/
    ├── 00-system/
    │   ├── nix-settings.nix        ✅ Nix-Daemon, GC, OOM-Traefik
    │   └── storage.nix             ⏸ Dummy (korrekt dokumentiert)
    ├── 10-infrastructure/
    │   ├── tailscale.nix           ✅ aktiv, importiert
    │   ├── traefik.nix             ⚠️ aktiv, aber ACME/sops auskommentiert
    │   ├── pocket-id.nix           ⚠️ ausgearbeitet, enable=false, nicht importiert
    │   ├── wireguard-vpn.nix       ⚠️ ausgearbeitet, nicht importiert
    │   ├── adguardhome.nix         ⏸ Dummy
    │   ├── clamav.nix              ⏸ Dummy
    │   ├── ddns-updater.nix        ⏸ Dummy
    │   └── valkey.nix              ⏸ Dummy
    ├── 20-backend-media/
    │   ├── sabnzbd.nix             ⚠️ ausgearbeitet, nicht importiert
    │   ├── prowlarr.nix            ⚠️ ausgearbeitet, nicht importiert
    │   ├── radarr.nix              ⏸ Dummy
    │   ├── sonarr.nix              ⏸ Dummy
    │   ├── readarr.nix             ⏸ Dummy
    │   ├── lidarr.nix              ⏸ Dummy
    │   └── recyclarr.nix           ⏸ Dummy
    ├── 30-frontend-media/
    │   ├── jellyfin.nix            ✅ ausgearbeitet + aktiv
    │   ├── audiobookshelf.nix      ✅ ausgearbeitet + aktiv
    │   └── jellyseerr.nix          ⏸ Dummy
    ├── 40-services/
    │   ├── open-webui.nix          ⏸ Dummy (nixpkgs-Bug #430433 prüfen!)
    │   └── alle anderen            ⏸ Dummy
    └── 90-services-enabled/        ⚠️ NEU – war nicht im ursprünglichen Plan
        └── default.nix             → schaltet jellyfin + audiobookshelf ein
```

---

## 4. 🚨 Sicherheitswarnungen – Sofortiger Handlungsbedarf

### Problem 1: WireGuard Private Key im Repo

`privado_wg_temp.conf` liegt im Repo-Root und enthält den Private Key im **Klartext**.
Dieser Key ist als **kompromittiert** zu betrachten.

```bash
# 1. Datei löschen und aus Git-History entfernen
git rm privado_wg_temp.conf
git commit -m "Remove plaintext WireGuard key"

# Falls bereits gepusht: BFG Repo-Cleaner oder git filter-repo nötig
# https://rtyley.github.io/bfg-repo-cleaner/

# 2. Neues Keypair bei AirVPN/Privado generieren
# 3. Neuen Key per secrets-setup.sh in sops einpflegen
```

### Problem 2: Cloudflare API Token kompromittiert

Der alte Cloudflare Token ist in einem früheren Chat-Verlauf erschienen und muss als kompromittiert gelten.

```bash
# Im Cloudflare Dashboard: alten Token revoken, neuen erstellen
# Permission: Zone → DNS → Edit, Zone: nur m7c5.de
# Dann per secrets-setup.sh in sops einpflegen
```

---

## 5. Architektur-Entscheidungen (final – nicht neu diskutieren)

### Storage

- **ext4** auf allen Partitionen – kein bcachefs, kein ZFS, kein mergerfs
- **Direkte HDD-Mountpoints** statt mergerfs: mergerfs weckt bei jedem `readdir()` alle HDDs auf (ironicbadger FAQ: "For Jellyfin, point to the underlying filesystems. Not mergerfs.")
- **hd-idle** für Spindown nach 600 Sekunden
- **Atomic Move** via `.staging/` Ordner auf derselben HDD – Rename muss auf gleicher HDD stattfinden, kein Cross-Device!
- **Apacer NVMe** als Download-Cache: SABnzbd lädt nach `/downloads/`, HDDs schlafen dabei

### Reverse Proxy

- **Traefik v3** – natives NixOS-Modul
- Let's Encrypt via **Cloudflare DNS-Challenge** (funktioniert hinter NAT, kein offener Port 80 für ACME nötig)
- Alle Services bekommen Subdomains: `service.m7c5.de`
- Kein direkter Port nach außen außer 80, 443, 22

### Authentifizierung / SSO

- **Pocket ID** als OIDC-Provider (~20 MB RAM, Go-Binary, Passkeys/FIDO2) für Tier-2-Services
- **Traefik ForwardAuth** Middleware (`pocket-id-auth@file`) für Services ohne OIDC-Support
- **Vaultwarden ohne SSO** – bewusst isoliert, eigener Login

### Secrets

- **sops-nix** + Age-Keys – verschlüsselt in Git versioniert
- SSH Host Key → Age Private Key konvertiert, in `/var/lib/sops-nix/key.txt` (600, niemals in Git!)
- Secrets im Format `KEY=VALUE` direkt in sops speichern → `systemd EnvironmentFile` versteht das direkt, kein Wrapper nötig

### VPN

- **Maroka-chan/VPN-Confinement** – Network Namespace Killswitch für SABnzbd (bereits in flake.nix als Input!)
- **AirVPN (Privado)** – statisches Port-Forwarding, wg-quick kompatibel
- VPN-Namespace: `privado`, SABnzbd Port-Mapping 8080→8080

### Jellyfin / Intel QuickSync

```nix
hardware.opengl.enable = true;
hardware.opengl.extraPackages = with pkgs; [
  intel-media-driver      # iHD für Gen 8+ (i3-9100 = Gen 9)
  vaapiIntel              # Legacy i965
  intel-compute-runtime   # OpenCL
];
users.users.jellyfin.extraGroups = [ "video" "render" ];
```

Der i3-9100 (UHD 630) schafft 3–5 gleichzeitige H.264/H.265-Streams via QuickSync bei ~5W Zusatzlast. Ohne QuickSync kollabiert der Server bei einem einzigen H.265-Stream.

### Abgelehnte Alternativen (endgültig)

| Was | Warum abgelehnt |
|---|---|
| mergerfs | Weckt alle HDDs auf – ironicbadger FAQ bestätigt |
| bcachefs | Zu jung, kein Tiering-Vorteil bei ~1,3 TB |
| ZFS | Special vdev zu teuer |
| Docker | 20+ Services haben native NixOS-Module |
| FreshRSS | nginx-Lock-in im NixOS-Modul |
| Redis | BSL-Lizenz seit 2024 → Valkey stattdessen |
| Authelia | Overkill für 1–5 User → Pocket ID |
| Keycloak | Enterprise-Overhead |
| Immich | Bewusst weggelassen |
| nixarr-Module | Zu wenig Kontrolle – nur als Referenz |

---

## 6. Service-Tiers & Zugriffskonzept

| Tier | Zugang | Services |
|---|---|---|
| 0 | Nur Tailscale | Homepage, Semaphore, Netdata, Scrutiny, Uptime Kuma, AdGuard, n8n |
| 1 | Tailscale + LAN | Prowlarr, Sonarr, Radarr, Readarr, SABnzbd (VPN), Jellyseerr, Lidarr |
| 2 | Internet + Pocket ID OIDC | Jellyfin, Audiobookshelf, Miniflux, Paperless, Linkding, Readeck |
| 3 | Isolierter eigener Login | Vaultwarden, Pocket ID, CouchDB, Home Assistant |

---

## 7. Verfügbare NixOS-Module (nixpkgs 24.11)

Native via `services.X.enable = true`:

| Service | NixOS-Option | In Repo |
|---|---|---|
| Traefik v3 | `services.traefik.enable` | ✅ aktiv |
| Tailscale | `services.tailscale.enable` | ✅ aktiv |
| fail2ban | `services.fail2ban.enable` | ✅ aktiv |
| Jellyfin | `services.jellyfin.enable` | ✅ aktiv |
| Audiobookshelf | `services.audiobookshelf.enable` | ✅ aktiv |
| Prowlarr | `services.prowlarr.enable` | ⚠️ Modul da, nicht importiert |
| SABnzbd | `services.sabnzbd.enable` | ⚠️ Modul da, nicht importiert |
| Pocket ID | `services.pocket-id.enable` | ⚠️ Modul da, enable=false |
| Jellyseerr | `services.jellyseerr.enable` | ⏸ Dummy |
| Sonarr | `services.sonarr.enable` | ⏸ Dummy |
| Radarr | `services.radarr.enable` | ⏸ Dummy |
| Lidarr | `services.lidarr.enable` | ⏸ Dummy |
| Readarr | `services.readarr.enable` | ⏸ Dummy |
| Recyclarr | `services.recyclarr.enable` | ⏸ Dummy |
| Vaultwarden | `services.vaultwarden.enable` | ⏸ Dummy |
| Paperless-ngx | `services.paperless.enable` | ⏸ Dummy |
| Miniflux | `services.miniflux.enable` | ⏸ Dummy |
| AdGuard Home | `services.adguardhome.enable` | ⏸ Dummy |
| Netdata | `services.netdata.enable` | ⏸ Dummy |
| Scrutiny | `services.scrutiny.enable` | ⏸ Dummy |
| n8n | `services.n8n.enable` | ⏸ Dummy |
| Home Assistant | `services.home-assistant.enable` | ⏸ Dummy |
| CouchDB | `services.couchdb.enable` | ⏸ Dummy |

**Nicht in nixpkgs – brauchen custom systemd-Service:** linkding, readeck, semaphore, uptime-kuma

---

## 8. Bekannte Inkonsistenzen / Tech Debt

| # | Problem | Fundstelle | Priorität |
|---|---|---|---|
| 1 | `privado_wg_temp.conf` mit Plaintext-WG-Key im Repo-Root | Repo-Root | 🚨 Sofort |
| 2 | Cloudflare Token aus Chat-Verlauf kompromittiert | – | 🚨 Sofort |
| 3 | sops-nix nicht als Input in flake.nix | flake.nix | 🔴 Hoch |
| 4 | `provider = "cloudflare"` in traefik.nix auskommentiert → kein ACME | traefik.nix | 🔴 Hoch |
| 5 | sops-Secret-Block in traefik.nix auskommentiert | traefik.nix | 🔴 Hoch |
| 6 | SSH-Port Widerspruch: firewall.nix listet Port 53844, ssh.nix nutzt 22 | hosts/common/core/ | 🟡 Mittel |
| 7 | `90-services-enabled/` war nicht im ursprünglichen Plan – Struktur-Frage | modules/ | 🟡 Klären |
| 8 | NixOS-Version: Plan sagte 25.11, tatsächlich ist es 24.11 | flake.nix | 🟡 Dokumentiert |
| 9 | `providers.docker` aktiv in traefik.nix, kein Docker-Daemon läuft | traefik.nix | 🟢 Niedrig |
| 10 | open-webui.nix: bekannte nixpkgs-Bugs (Issue #430433) | modules/40-services/ | 🟢 Beobachten |

---

## 9. sops-nix – Vollständige Referenz

### Einmalig-Setup (manuell erledigt, NICHT in flake.nix deklariert!)

```bash
sudo mkdir -p /var/lib/sops-nix
sudo bash -c 'nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key" \
  > /var/lib/sops-nix/key.txt'
sudo chmod 600 /var/lib/sops-nix/key.txt
```

Age Public Key (in `.sops.yaml`, public-safe):
```
age1t2uu2un4trvvyhg7ryp8h8tqjxl5vnd0qd48dq4s8yvhc6jwtd4smyet95
```

### sops-nix in flake.nix ergänzen (noch offen!)

```nix
inputs = {
  nixpkgs.url        = "github:nixos/nixpkgs/nixos-24.11";
  disko.url          = "github:nix-community/disko";
  disko.inputs.nixpkgs.follows = "nixpkgs";
  vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  vpn-confinement.inputs.nixpkgs.follows = "nixpkgs";
  # NEU:
  sops-nix.url       = "github:Mic92/sops-nix";
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
  nixosConfigurations.q958 = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/q958
      sops-nix.nixosModules.sops  # ← NEU
    ];
  };
};
```

### Gelernte Lektion: KEY=VALUE Format

sops-nix legt Secrets als Datei ab. `systemd EnvironmentFile` erwartet `KEY=VALUE`. Deshalb Werte direkt in diesem Format in sops speichern:

```yaml
# secrets.sops.yaml (entschlüsselt, nur lokal sichtbar)
cloudflare_api_token: "CF_DNS_API_TOKEN=deinTokenHier"
privado_wg_key: "DEIN_WG_PRIVATE_KEY"
```

```nix
# In der Config dann einfach:
systemd.services.traefik.serviceConfig.EnvironmentFile = [
  config.sops.secrets."cloudflare_api_token".path
];
# Kein preStart-Wrapper nötig!
```

### Aliase für sops (in nix-settings.nix)

```nix
environment.shellAliases = {
  sops-edit = "sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops /home/moritz/nix-config/secrets.sops.yaml'";
  sops-show = "sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops -d /home/moritz/nix-config/secrets.sops.yaml'";
};
```

### Secrets-Übersicht

| Key in sops | Zweck | Format |
|---|---|---|
| `cloudflare_api_token` | Traefik ACME DNS-Challenge | `CF_DNS_API_TOKEN=xxx` |
| `privado_wg_key` | WireGuard VPN (AirVPN) | Reiner Key-String |
| `pocket_id_secret` | Pocket ID Token-Signing | Zufälliger String |
| `sabnzbd_api_key` | SABnzbd API-Zugriff | Reiner Key |
| `vaultwarden_admin_token` | Vaultwarden Admin | Zufälliger String |
| `paperless_secret_key` | Paperless Django Secret | Zufälliger String |
| `miniflux_admin_password` | Miniflux Admin | Passwort |
| `linkding_secret_key` | Linkding Secret | Zufälliger String |
| `n8n_encryption_key` | n8n Datenverschlüsselung | Zufälliger String |
| `semaphore_cookie_hash` | Semaphore Session | 32+ Zeichen |
| `valkey_password` | Valkey/Redis Auth | Passwort |
| `openai_api_key` | Open WebUI Backend | `sk-...` |

---

## 10. Traefik – Patterns & aktueller Zustand

### Aktueller traefik.nix Zustand

Traefik startet und Port 80/443 sind offen. Folgendes ist **auskommentiert** und muss reaktiviert werden:
- sops-Secret-Block (cloudflare_api_token)
- `provider = "cloudflare"` in dnsChallenge
- Weiterhin aktiv (aber eigentlich nicht nötig): `providers.docker` – Docker läuft nicht

Als Validierungs-Workaround läuft ein `whoami`-OCI-Container unter `nix-whoami.m7c5.de` – aber ohne funktionierenden ACME-Provider kommt kein Zertifikat.

### Router-Muster pro Service

```nix
services.traefik.dynamicConfigOptions.http = {
  routers.meinservice = {
    rule            = "Host(`meinservice.m7c5.de`)";
    entryPoints     = [ "websecure" ];
    tls.certResolver = "letsencrypt";
    middlewares     = [ "secure-headers@file" ];
    # Für Tier 2 zusätzlich: "pocket-id-auth@file"
    service         = "meinservice";
  };
  services.meinservice.loadBalancer.servers = [{ url = "http://127.0.0.1:PORT"; }];
};
```

### Wichtig: ACME holt Zertifikate erst wenn ein Router existiert!

Leeres `acme.json` ist normal solange kein Service-Router aktiv ist. Das war kein Bug.

---

## 11. Priorisierte To-Do Liste

### 🚨 Sicherheit – Jetzt sofort

- [ ] `privado_wg_temp.conf` aus Git-History entfernen (BFG Repo-Cleaner)
- [ ] Neues WireGuard-Keypair bei AirVPN generieren, in sops einpflegen
- [ ] Neuen Cloudflare API Token erstellen, in sops einpflegen

### 🔴 Blocker – ACME/TLS zum Laufen bringen

- [ ] **sops-nix als Input in flake.nix** ergänzen (siehe Abschnitt 9)
- [ ] **sops-nix NixOS-Modul** in flake.nix outputs einbinden
- [ ] **sops-Block in traefik.nix** wieder einkommentieren (mit neuem CF-Token)
- [ ] **`provider = "cloudflare"`** in traefik.nix einkommentieren
- [ ] **SSH-Port-Widerspruch** beheben: Port 53844 aus firewall.nix entfernen, nur Port 22
- [ ] Rebuild und prüfen ob ACME Wildcard-Zert holt (kann 2–5 Min dauern)
- [ ] `providers.docker` aus traefik.nix entfernen (kein Docker-Daemon aktiv)

### 🟡 Nächste Services aktivieren

- [ ] **Vaultwarden** – erster Produktiv-Service, kaum Abhängigkeiten
- [ ] **Homepage** – Dashboard für Überblick aller Services
- [ ] **Prowlarr** – Modul ausgearbeitet, nur Import in default.nix nötig
- [ ] **SABnzbd + VPN-Confinement** – Modul ausgearbeitet, wireguard-vpn.nix importieren
- [ ] **Sonarr, Radarr, Readarr** – ARR-Stack
- [ ] **Pocket ID** – `enable = false` → `true`, sops-Secret einbinden
- [ ] `90-services-enabled/` Struktur überdenken: beibehalten oder Services direkt in ihre Module?

### 🟢 Storage & Infrastruktur

- [ ] HDDs anschließen, Disk-IDs ermitteln: `ls -la /dev/disk/by-id/`
- [ ] storage.nix befüllen: ext4-Mounts per `by-id`, `nofail`, hd-idle nach 600s
- [ ] `.staging/` Ordner auf jeder HDD für atomic SABnzbd-Moves anlegen
- [ ] AdGuard Home (nur Tailscale/LAN)
- [ ] **DNS-Cutover m7c5.de → Q958** – **ALLERLETZTER SCHRITT, erst wenn alles stabil**

### ⚪ Niedrige Priorität / Später

- [ ] Miniflux, Paperless, Linkding, Readeck, Jellyseerr
- [ ] Home Assistant + CouchDB
- [ ] n8n, Semaphore, Netdata, Scrutiny, Uptime Kuma
- [ ] Open-WebUI (erst nach nixpkgs-Bugfix: Issue #430433 prüfen!)
- [ ] Cache-Mover-Skript (n8n-Workflow: SSD → HDD nach 30 Tagen ohne Wiedergabe)
- [ ] disko.nix für reproduzierbare Neuinstallation dokumentieren

---

## 12. Gelernte Lektionen

- **sops 3.x** unterstützt `SOPS_AGE_SSH_PRIVATE_KEY_FILE` nicht mehr → SSH-Key muss per `ssh-to-age` zu Age-Key konvertiert werden
- **EnvironmentFile erwartet KEY=VALUE** – Wert direkt in diesem Format in sops speichern, kein preStart-Wrapper nötig
- **sops-nix muss als Flake-Input deklariert sein** – nur den Age-Key auf der Festplatte zu haben reicht nicht
- **Traefik loggt ACME erst wenn ein Router existiert** – leeres `acme.json` ist ohne aktive Services normal
- **ACME braucht den Cloudflare Provider** – ohne `provider = "cloudflare"` passiert gar nichts
- **mergerfs weckt alle HDDs auf** – direkte Mountpoints sind für Spindown-Betrieb die einzig korrekte Lösung
- **Swap hilft** bei RAM-intensiven Builds (Sonarr/Radarr Dotnet-Runtime)
- **Dirty Git-Tree** verhindert keinen Rebuild, gibt nur eine Warnung
- **Plaintext-Secrets niemals in Git** – `privado_wg_temp.conf` war ein Fehler
- **fail2ban ist sinnvoll** auch hinter Tailscale, da Port 22 öffentlich offen ist

---

## 13. Referenz-Repositories

| Repo | Zweck | Status |
|---|---|---|
| [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config) | Hauptvorbild – hosts/common/core Pattern | Umgesetzt ✅ |
| [ironicbadger/pms-wiki](https://github.com/ironicbadger/pms-wiki) | Perfect Media Server, Storage-Entscheidungen | Berücksichtigt ✅ |
| [Maroka-chan/VPN-Confinement](https://github.com/Maroka-chan/VPN-Confinement) | VPN Killswitch für SABnzbd | In flake.nix ✅ |
| [nix-community/disko](https://github.com/nix-community/disko) | Deklarative Partitionierung | In flake.nix ✅, noch nicht genutzt |
| [Mic92/sops-nix](https://github.com/Mic92/sops-nix) | Secrets Management | **Noch nicht in flake.nix!** ❌ |

---

## 14. Wichtige Befehle

```bash
# Rebuild (im ~/nix-config Verzeichnis)
sudo nixos-rebuild test   --flake .#q958 |& nom   # Testen, kein persistenter Effekt
sudo nixos-rebuild switch --flake .#q958 |& nom   # Deployen

# Nach Rebuild einchecken
git add -A && git commit -m "beschreibung" && git push

# Flake updaten
nix flake update

# sops Secrets bearbeiten / anzeigen
sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops /home/moritz/nix-config/secrets.sops.yaml'
sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops -d /home/moritz/nix-config/secrets.sops.yaml'

# Disk-IDs anzeigen (für storage.nix)
ls -la /dev/disk/by-id/

# Service-Status
systemctl status traefik tailscaled jellyfin audiobookshelf

# Traefik Logs (DEBUG aktiv!)
journalctl -u traefik -f

# SSH vom Laptop
ssh moritz@192.168.2.250

# Nix Store aufräumen
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
sudo nix-store --gc

# Bei Fehler: alte Generation im GRUB wählen
# Beim Booten: NixOS → ältere Generation auswählen
```

---

## 15. Backup-Strategie

| Was | Wohin | Tool |
|---|---|---|
| `/var/lib/` (Appdata) | Externe USB-HDD | Restic (noch nicht eingerichtet) |
| `~/nix-config` | GitHub (öffentlich) | Git |
| `secrets.sops.yaml` | Git (verschlüsselt via sops) | sops-nix |
| `/storage/hddX/` | Kein Backup – Medien wiederbeschaffbar | – |
| Jellyfin Metadata | Kein Backup – wird neu gescannt | – |
