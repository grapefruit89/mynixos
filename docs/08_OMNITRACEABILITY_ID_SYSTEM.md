---
title: NixOS Homelab Omnitraceability & ID System
project: NMS v2.3
last_updated: 2026-03-02
status: High-Confidence System Feature
type: Documentation & Audit Framework
---

# 🔍 OMNITRACEABILITY & ID SYSTEM

Dieses Dokument beschreibt das Rückgrat der Dokumentations- und Audit-Logik im NixOS-Homelab: das **Source-ID / Sink** System.

## 🏗️ Das Konzept der Omnitraceability

Omnitraceability bedeutet, dass jede Konfigurationsentscheidung vom physischen Code bis zur strategischen Dokumentation lückenlos nachverfolgbar ist. Dies wird durch ein striktes ID-Schema erreicht.

### 1. CFG-IDs (Source of Truth)
Jeder zentrale Wert in `00-core/configs.nix` (IPs, Domains, Ports) erhält eine eindeutige ID.
- **Muster**: `# source-id: CFG.<gruppe>.<key>`
- **Zweck**: Markierung der "Single Source of Truth" (SSoT).

### 2. Sink-Tracking
In den Modulen (Layer 10 & 20) wird die Verwendung dieser Werte markiert.
- **Muster**: `# sink: CFG.<gruppe>.<key>` oder `# sink-id: ...`
- **Zweck**: Nachweis, wo globale Einstellungen physisch im System "landen".

---

## 🔬 ID-Nomenklatur & Audit-IDs

Das System nutzt spezifische Präfixe für verschiedene Audit-Zwecke:

| Präfix | Bedeutung | Beispiel |
|---|---|---|
| **CFG.** | Konfigurations-Parameter | `CFG.identity.domain` |
| **NIXH-** | Architektur-Anforderungen | `NIXH-00-CORE-012` |
| **SEC-** | Sicherheits-Policy / Invarianten | `SEC-SSH-SVC-001` |
| **P0/P1/P2** | Audit-Befunde (Schweregrad) | `NIXH-AUDIT-P0-001` |

---

## 🤖 Automatisierung: Das ID-Report System

Um die Traceability aktuell zu halten, wird das Script **`scripts/scan-ids.sh`** eingesetzt.

### Funktionsweise:
1. **Scan**: Durchsucht alle `.nix` und `.md` Dateien nach `source-id:` und `sink`.
2. **Abgleich**: Prüft, ob jede `source-id` auch entsprechende `sinks` hat (Vermeidung von "totem Code").
3. **Generierung**: Erstellt automatisch den **`00-core/ids-report.md`** und **`.json`**.

### Integration:
Der Scan ist Teil des `nix-deploy.sh` Workflows. Ein Build startet nur, wenn die Traceability-Matrix valide ist.

---

## 💎 Goldnuggets der Traceability

- **Requirement-Linking**: In den Datei-Headern werden `upstream` (Abhängigkeit) und `downstream` (Konsumenten) IDs gepflegt.
- **Complexity Score**: Jedes Modul erhält eine Bewertung (1-5), um den Wartungsaufwand abzuschätzen.
- **Technical Integrity**: Dateien enthalten Checksummen und `eof_marker` (`NIXHOME_VALID_EOF`), um Manipulationen oder unvollständige Übertragungen zu erkennen.

---
*Dokument Ende.*
