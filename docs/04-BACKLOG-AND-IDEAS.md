---
title: Backlog & Ideen
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-BCK-001
description: Zukünftige Projekte, Optimierungen und Visionen.
---

# 💡 Backlog & Ideen

## 1. Geplante Verbesserungen

*   **[ ] Dashboard-Upgrade:** Ersetzen des Vanilla Bash-MOTD durch `fastfetch` für schicke ASCII-Art, automatische Mount-Kapazitätsanzeige und detaillierteren Service-Status.
*   **[ ] Monitoring:** Integration eines vollständigen Monitoring-Stacks mit `Netdata` für Echtzeit-Metriken und `Scrutiny` für die Überwachung der HDD-Gesundheit (S.M.A.R.T.).
*   **[ ] Backup-Automatisierung:** Implementierung eines robusten Backup-Concepts für die State-Verzeichnisse unter `/data/state` (z.B. via Restic oder Borg).
*   **[ ] Secrets Evolution:** Migration von manuellen ENV-Dateien zu `sops-nix` oder `agenix`, sobald das System auf Flakes umgestellt wird.

## 2. Langzeit-Ideen

*   **FIDO2 / SSH:** Umstellung der SSH-Authentifizierung auf Hardware-Keys (Yubikey).
*   **IPv6:** Vollständige IPv6-Unterstützung im internen Netz und via Traefik.
*   **Public Routes:** Fein-Granulare Steuerung, welche Dienste wirklich über das öffentliche Internet (Cloudflare Proxy) erreichbar sein sollen.
