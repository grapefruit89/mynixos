---
title: NixOS Homelab Codebase Health & Cleanup Tasks
project: NMS v2.3
last_updated: 2026-03-02
status: Active Backlog
type: Maintenance Log
---

# 🧹 CODEBASE HEALTH & CLEANUP TASKS

Dieses Dokument listet identifizierte technische Schulden und notwendige Korrekturen am Codebestand.

## 🛠️ Identifizierte Fehler & Bugs

### 1. `cloudflared-tunnel.nix`: Pattern Fehler
- **Problem**: `wildcardPrefix` wird falsch interpoliert (`nix-*.m7c5.de`). Dies bricht klassische Host-Matches.
- **Task**: Trennung in `subdomainPattern` (z.B. `*.m7c5.de`) und einen dedizierten Hostnamen für `originServerName` (ohne Wildcard).

### 2. `netdata.nix`: Dokumentations-Fehler
- **Problem**: Kopfkommentar verweist auf `modules/40-services/`, Datei liegt aber in `20-services/apps/`.
- **Task**: Pfad im Header korrigieren.

### 3. Port-Duplizierung: PocketID
- **Problem**: Port 3000 ist an drei verschiedenen Stellen hardcodiert.
- **Task**: Zentralisierung in `ports.nix` (Vorgesehener Port: 10010) und Referenzierung via `config.my.ports.pocketId`.

## 🗑️ Cleanup (Deprecation)

Folgende Dateien sind veraltet und sollten nach der nächsten stabilen Phase gelöscht werden:
- `00-core/server-rules.nix` (Inhalt nach `90-policy/security-assertions.nix` verschoben).
- `00-core/de-config.nix` (Inhalt in `00-core/locale.nix` konsolidiert).
- `00-core/dummy.nix` (Reine Kopiervorlage).

---
*Dokument Ende.*
