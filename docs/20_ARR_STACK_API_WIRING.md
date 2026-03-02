---
title: NixOS Homelab ARR Stack API Wiring
project: NMS v2.3
last_updated: 2026-03-02
status: Active Automation
type: Service Configuration
---

# 🎬 ARR STACK API WIRING

Dieses Dokument erklärt die automatisierte Vernetzung der Media-Services (Sonarr, Radarr, Prowlarr, SABnzbd) via API.

## 🤖 Der `arr-wire.service`

Anstatt API-Keys manuell in vier verschiedenen Web-UIs einzutragen, nutzt das System einen automatisierten systemd-Helper.

### Funktionsweise:
1.  **Trigger**: Der Dienst (`arr-wire.service`) läuft einmalig beim Booten oder manuell via `systemctl start`.
2.  **Secret Ingestion**: Er liest die API-Keys aus `/etc/secrets/homelab-runtime-secrets.env`.
3.  **Cross-Wiring**:
    - Registriert Prowlarr Indexer in Sonarr/Radarr.
    - Registriert SABnzbd als Download-Client in Sonarr/Radarr.
    - Setzt die korrekten URLs (`http://127.0.0.1:<PORT>`) unter Berücksichtigung des zentralen Port-Schemas.

## 🏥 Validierung & Health
Der Service führt vor dem Schreiben der Konfiguration einen Health-Check durch:
- Prüft, ob der Ziel-Dienst antwortet (HTTP 200).
- Vergleicht den vorhandenen Key mit dem Soll-Zustand.
- Loggt Abweichungen detailliert (`journalctl -u arr-wire`).

## 🔄 Manuelle Key-Rotation
Wenn API-Keys in der `.env`-Datei geändert werden:
1.  Werte in `/etc/secrets/homelab-runtime-secrets.env` aktualisieren.
2.  Dienst ausführen: `sudo systemctl start arr-wire.service`.
3.  Logs prüfen: `sudo journalctl -u arr-wire -n 100 --no-pager`.

---
*Dokument Ende.*
