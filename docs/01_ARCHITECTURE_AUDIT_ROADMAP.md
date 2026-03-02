---
title: NixOS Homelab Architecture Audit & Roadmap
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (Full Knowledge Enrichment)
type: Architecture & Strategy
---

# 🏗️ ARCHITECTURE AUDIT & ROADMAP

Dieses Dokument bündelt die brutale Analyse des Gesamtsystems, strategische Entscheidungen und den Fahrplan.

## 📊 Zugriffskonzept: Die Service-Tiers

Das Projekt folgt einem strikten Zonenschema für den Zugriff:

| Tier | Erreichbarkeit | Dienste (Beispiele) |
|---|---|---|
| **Tier 0** | Nur Tailscale | Homepage, Semaphore, Netdata, AdGuard, n8n |
| **Tier 1** | Tailscale + LAN | Prowlarr, Sonarr, Radarr, SABnzbd |
| **Tier 2** | Internet + PocketID | Jellyfin, Audiobookshelf, Miniflux, Paperless |
| **Tier 3** | Eigener Login (Isoliert) | Vaultwarden, PocketID, Home Assistant |

---

## 🔬 Abgelehnte Alternativen (Design Rationale)

Um das System schlank und wartbar zu halten, wurden folgende Ansätze bewusst verworfen:
- **ZFS**: Verworfen, da "Special VDEVs" für SSD-Caching zu teuer/komplex für dieses Setup sind.
- **Docker**: Verworfen zugunsten nativer NixOS-Module (bessere Integration, deklarative Konfiguration).
- **Authelia/Keycloak**: Verworfen, da PocketID für 1-5 Nutzer wesentlich leichtgewichtiger ist.
- **Bcachefs**: Aktuell noch zu experimentell ("zu jung") für ein stabiles Homelab.

---

## 🔴 Kritische Audit-Befunde (Layer 00-CORE)

### 1. Die /boot-Partition Zeitbombe
- **Befund**: 96MB VFAT Partition ist zu 68% voll.
- **Fix**: Reduktion auf `configurationLimit = 2`. Implementierung von `nix.gc.automatic`.

> **[NixOS Expert-Einschub: ESP-Überlauf verhindern]**
> Bei einer extrem kleinen `/boot` Partition (96MB) empfiehlt die Community zusätzlich:
> - `boot.loader.grub.useOSProber = false;` (spart Platz für zusätzliche Boot-Einträge).
> - `boot.loader.systemd-boot.editor = false;` (Sicherheits- und Platzvorteil).
> - **Strategischer Tipp**: Falls der Platz dauerhaft nicht reicht, kann NixOS so konfiguriert werden, dass nur der Kernel/Initrd auf `/boot` liegen, während die Generationen-Links in `/nix` verbleiben (XBOOTLDR-Pattern).

### 2. Storage-Tiering & Boot-Resilience
- **Befund**: Fehlendes `nofail` bei Tier-B SSDs blockiert den Bootvorgang.
- **Fix**: Alle Mounts in `storage.nix` erhalten `nofail` und `x-systemd.mount-timeout=10s`.

---

## 🗺️ Strategischer Projektplan (Roadmap)

### Phase 1: Stabilisierung (Sofort)
- [ ] **Boot-Safeguard**: `pre-nixos-rebuild-check.sh` als systemd-Pflicht-Gate.
- [ ] **Secrets Hygiene**: History-Rewrite für kompromittierte Keys im Git-Repo.

### Phase 2: Infrastruktur & Zero-Trust (Nächste 2 Wochen)
- [ ] **Break-Glass Zugang**: Tailscale-only Ingress ohne SSO-Pflicht für Notfälle.
- [ ] **IP-Zentralisierung**: Umstellung von AdGuard auf dynamische Adress-Referenzen.
- [ ] **Aviation Grade Cloud Backup**:
    - [ ] Integration von Restic mit S3 (Backblaze B2 / AWS).
    - [ ] Verschlüsselung via SOPS (Age).
    - [ ] Health-Monitoring via Uptime Kuma (Push-Heartbeat).

### Phase 3: "Holy State" & Flakes
- [ ] **Impermanence**: Umstellung von `/` auf `tmpfs`.
- [ ] **Flake Integration**: Pinning der Inputs via `flake.lock`.

> **[NixOS Expert-Einschub: Impermanence Best-Practice]**
> Beim Wechsel auf `tmpfs` (Holy State) tritt oft das Problem auf, dass `.bash_history` bei einem harten Reboot verloren geht. 
> **Lösung**: `programs.bash.interactiveShellInit = "trap 'history -a' EXIT";` in die Config aufnehmen, um den History-Flush vor dem Wipe zu erzwingen.

---
*Ende des Berichts.*
