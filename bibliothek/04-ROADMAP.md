---
title: Roadmap & Zukunft
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-ROAD-001
description: Projektfortschritt und geplante Optimierungen.
---

# 🗺️ Roadmap & Zukunft

## ✅ Abgeschlossen (26.02.2026)

*   **Netzwerk-Power:** TCP BBR Congestion Control aktiviert und Buffer auf 32MB optimiert (Streaming-Boost).
*   **Intelligenter Speicher:** MergerFS Tier-Modell (ABC) implementiert. Cache-Optionen verhindern HDD-Wakeups beim Browsen.
*   **Smart Mover:** Skript + Timer erstellt, das Daten basierend auf Alter, SSD-Füllstand und HDD-Spin-Status verschiebt.
*   **Automatisches Backup:** Restic sichert täglich um 02:00 AM die Tier-A Daten (Apps/Configs) lokal.
*   **Auth-Zentrale:** Pocket-ID aktiviert und via `auth.${domain}` erreichbar.
*   **Direkt-Einstieg:** Der Server ist jetzt unter `http://nixhome.local` direkt über das Homepage-Dashboard erreichbar.

## ⏳ Geplante Verbesserungen

*   **[ ] Dashboard-Upgrade:** Ersetzen des Vanilla Bash-MOTD durch `fastfetch` für schicke ASCII-Art und detaillierteren Status.
*   **[ ] Monitoring:** Evaluation von Cockpit oder einem ähnlichen GUI für grafisches HDD-Monitoring.
*   **[ ] Maintainerr:** Setup zur automatischen Löschung bereits gesehener Medien im Arr-Stack.
*   **[ ] IPv6 Transition:** Volle IPv6 Unterstützung für alle internen Dienste.

---
👉 [**Handbuch Index**](Handbuch_Index.md)
