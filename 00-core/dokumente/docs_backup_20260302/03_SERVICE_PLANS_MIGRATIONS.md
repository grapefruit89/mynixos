---
title: NixOS Homelab Service Plans & Migrations
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated
type: Service Migration & Deployment
---

# 🚀 SERVICE PLANS & MIGRATIONS

Dieses Dokument beschreibt die geplanten Migrationen und das Deployment-Schema für die Dienste im NixOS-Homelab.

## 🏗️ Universal Flake Architektur (Ziel)

Der Zielzustand für alle Services ist eine modulare, flake-basierte Struktur nach dem **nixarr-Prinzip**.

### Kernprinzipien:
1. **Implementierung ≠ Konfiguration**: Module definieren *was* ein Dienst kann, die Host-Config definiert *wie* er läuft.
2. **Kapselung**: Jeder Dienst lebt in `modules/services/<name>.nix`.
3. **Reproduzierbarkeit**: `flake.lock` pinnt alle Abhängigkeiten exakt.

---

## 🗂️ Paperless-ngx Schlachtplan

### Ziel: Migration zur professionellen Flake-Architektur
- **Modul**: `modules/services/paperless.nix`.
- **Features**: OCR (deu/eng), PDF/A Output, Redis Task-Queue (Valkey), PostgreSQL Backend.
- **Backup**: Automatisches Dokumenten-Export-Script via Systemd-Timer.

---

## 🎬 Media-Stack (arr-Suite)

Alle arr-Dienste nutzen ein gemeinsames Blueprint (`_lib.nix`) für konsistente Härtung und Konfiguration.

### Port-Schema (Zentralisiert in `ports.nix`)
Um Kollisionen zu vermeiden, wird ein strenges 10k/20k Schema eingeführt:

| Dienst | Bereich | Port |
|---|---|---|
| SSH | Core | 53844 |
| AdGuard | Infra (10k) | 10001 |
| Netdata | Infra (10k) | 10002 |
| Homepage | Infra (10k) | 10004 |
| Vaultwarden | Apps (20k) | 20001 |
| Paperless | Apps (20k) | 20004 |
| Jellyfin | Media (21k) | 21001 |
| Sonarr | Media (21k) | 21003 |

---

## 🚇 VPN Confinement & DNS Leak Protection

Dienste wie `sabnzbd` oder der Media-Stack können selektiv in einen WireGuard-Namespace (`privado`) verschoben werden.

### Maßnahmen:
- `RestrictNetworkInterfaces = [ "lo" "privado" ]` im Systemd-Service.
- DNS-Leak Mitigation durch Erzwingen der VPN-DNS Server in der Service-Umgebung.
- Automatisches VPN-Monitoring (Restart des Namespaces bei Ping-Loss).

---

## 🔄 Migrationsleitfaden (Schritt-für-Schritt)

1. **Globale Optionen definieren**: `modules/global/options.nix` für Domain, VPN-Toggles und Pfade.
2. **Dienst portieren**: Modul aus Blueprint erstellen und in `modules/default.nix` importieren.
3. **Secrets migrieren**: Passwörter und Tokens in `secrets.yaml` verschieben.
4. **Alte Config bereinigen**: Flache Einträge aus `configuration.nix` nach erfolgreichem Test löschen.

---
*Dokument Ende.*
