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

Anstatt API-Keys manuell in Web-UIs einzutragen, nutzt das System den `arr-wire.service` (oneshot).

### Funktionsweise:
1.  **Secret Ingestion**: Liest API-Keys aus `/etc/secrets/homelab-runtime-secrets.env`.
2.  **Cross-Wiring**:
    - Registriert Prowlarr Indexer in Sonarr/Radarr.
    - Registriert SABnzbd als Download-Client.
    - Setzt URLs unter Berücksichtigung des zentralen Port-Schemas.

## 🏥 Validierung & Health (Safe by Default)
Der Service ist bewusst "safe by default" konzipiert:
- **Pre-Check**: Prüft, ob der Ziel-Dienst antwortet (HTTP 200).
- **No-Overwrite Policy**: Wenn ein Key bereits korrekt gesetzt ist, wird nichts überschrieben. Dies verhindert inkonsistente Zustände bei Key-Rotationen.
- **Logging**: Abweichungen werden detailliert protokolliert (`journalctl -u arr-wire`).

## 🔄 Manuelle Key-Rotation
1.  Werte in `/etc/secrets/homelab-runtime-secrets.env` aktualisieren.
2.  Dienst ausführen: `sudo systemctl start arr-wire.service`.
