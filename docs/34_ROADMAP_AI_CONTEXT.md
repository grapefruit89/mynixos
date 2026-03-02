---
title: NixOS Homelab Roadmap & AI Context
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Enriched)
type: Strategy & Governance
---

# 🗺️ ROADMAP & AI CONTEXT

## 🤖 AI Context & Golden Rules
Für jede KI, die an diesem Repo arbeitet, gelten diese Gesetze:
1. **Keine Flakes (aktuell)**: Die Struktur muss jedoch "Flake-ready" sein.
2. **Vanilla vor Abstraktion**: Standard-Optionen bevorzugen (KISS).
3. **SSoT**: IPs und Ports nur via `configs.nix` oder `ports.nix`.
4. **Sprache**: Kommentare und Erklärungen immer in **DEUTSCH**.

> **[NixOS Expert-Einschub: AI-Friendly Codebase]**
> Um die Arbeit mit Agenten wie Claude oder Gemini zu optimieren:
> - Nutze `lib.mkIf` anstelle von tief verschachtelten If-Else Blöcken.
> - Halte Module < 300 Zeilen.
> - **Traceability**: Nutze das `source-id: <ID>` Muster konsequent, damit der Agent bei Refactorings keine Abhängigkeiten "vergisst".

## ⏳ Strategischer Ausblick (Phase 3+)
- **Binary Cache (Cachix)**: Auslagerung von Builds, um den USB-Stick/SSD zu schonen.
- **Maintainerr Setup**: Automatisierte Mediathek-Pflege (Jellyfin -> Sonarr).
- **SQLite WAL-Mode**: Standardisierung für alle DBs (Schutz vor Datenverlust bei Stromausfall).
- **Fastfetch Dashboard**: Modernisierung des Login-MOTD für den 2026er Look.

> **[NixOS Expert-Einschub: Chat-Wissen konservieren]**
> Da wertvolles Wissen oft in Chats verloren geht, empfiehlt sich das Tool `AIChatExporter`. Es kann Konversationen aus Claude/ChatGPT/Gemini direkt in Markdown exportieren, die wir dann in den `old_files/` Ordner bündeln, um die "Bibliothek" kontinuierlich zu füttern.
