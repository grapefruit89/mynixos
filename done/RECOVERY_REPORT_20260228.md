# 🏥 Recovery Report — Obduktions-Heilung (Phase 1)
**Datum:** 2026-02-28  
**Status:** Phase 1 abgeschlossen

## Durchgeführte Maßnahmen (Audit-Fixes)

### 1. Reverse-Proxy & Auth (Caddy Migration)
- **Traefik -> Caddy:** Vollständiger Umstieg auf Caddy. Bessere Performance auf schwacher Hardware.
- **Break-Glass (SSO Bypass):** Tailscale-IPs (100.64.0.0/10) dürfen SSO (PocketID) überspringen. Schutz gegen Aussperren.
- **Henne-Ei HTTPS:** Caddy nutzt für den ersten Boot (Setup) Self-Signed Zertifikate, bis Cloudflare konfiguriert ist.

### 2. Boot & Hardware
- **NVRAM Schutz:** Limitierung der Boot-Generationen auf **3**.
- **WiFi Portabilität:** Firmwares und Module reaktiviert, um den Stick auf Consumer-Hardware (2020+) bootfähig zu halten.
- **UEFI-Only:** Bestätigung der UEFI-Architektur (kein Legacy-BIOS Müll).

### 3. Headless Rescue & UX
- **IP-Detection:** Landing Zone UI zeigt jetzt die eigene lokale IP an.
- **MOTD Update:** Login zeigt IP und Setup-Link grün hervorgehoben an.

## Nächste Schritte
- Implementierung des **Config-Merger** Services, um Nix-Wahrheit und User-JSON-Wahrheit zu vereinen.
- Systemd-Hardening für alle Proxy-Dienste.
