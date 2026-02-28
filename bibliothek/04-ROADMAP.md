---
title: Roadmap & Obduktions-Heilung (Recovery Phase)
author: Moritz / Gemini-Agent
last_updated: 2026-02-28
status: active
source_id: DOC-ROAD-002
description: Projektfortschritt und strategische Heilung nach dem Kernschicht-Audit.
---

# 🗺️ Roadmap & Zukunft

## ✅ Abgeschlossen (28.02.2026) — Obduktions-Fixes & AI-Boost
*   **[P0] Break-Glass Access:** SSO-Bypass für Tailscale-IPs (100.64.0.0/10) via Caddy.
*   **[P0] HTTPS Henne-Ei:** Self-Signed Fallback für Caddy (Phase 0).
*   **[P0] Connectivity:** `sslip.io` Fallback für `nixhome.local` integriert. Schluss mit der mDNS-Diva.
*   **[P1] AI Agents:** **Kimi K2.5 + Claude Code** integriert. Nutze `kimi` im Terminal.
*   **[P1] Legacy Purge:** Alles vor 2010 (GRUB, cron, ifconfig, SMBv1, nscd) ist raus.
*   **[P1] NVRAM Schutz:** Boot-Generationen auf hartes Limit von 3 reduziert.
*   **[P2] Caddy Migration:** Vollständige Ablösung von Traefik durch Caddy.

## ⏳ Phase 3: Performance & Stick-Härtung (Nächste Schritte)

### 📦 Binary Cache (Cachix/Attic)
*   **[ ] Cachix-Setup:** Verbindung zu `nixhome.cachix.org` herstellen.
*   **[ ] Stick-Optimierung:** Alle Binaries (insb. Kimi/Ollama) in den Cache schieben, um lokale Builds auf dem Stick zu verhindern.
*   **[ ] Nix-Daemon Tuning:** RAM-Limits für Rebuilds auf 4GB-Hardware (OOM-Schutz).

### 🏗️ Architektur (Der letzte Schliff)
*   **[ ] Config-Merger Service:** (In Arbeit) Vollständige Automatisierung des Nix-JSON-Merges.
*   **[ ] SQLite WAL-Mode:** Für PocketID und alle SQLite-Apps (Schutz vor Steckerziehen).
*   **[ ] Dashboard v2:** Integration von `fastfetch` für den 2026er Look.

---
👉 [**Handbuch Index**](Handbuch_Index.md)
