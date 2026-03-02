---
title: NixOS Homelab Metadata Standards & Integrity
project: NMS v2.3
last_updated: 2026-03-02
status: System-Wide Standard
type: Technical Specification
---

# 🤖 METADATA STANDARDS & INTEGRITY

Dieses Dokument definiert die maschinenlesbaren Standards für Header, Footer und Integritätsprüfungen innerhalb des NixOS-Homelabs. Ziel ist eine optimale Interaktion mit KI-Agenten und automatisierten Audit-Tools.

## 📄 YAML Frontmatter (Dokumentations-Standard)

Jede Markdown-Datei im Projekt muss mit einem YAML-Block beginnen. Dies ermöglicht KI-Modellen wie Gemini oder Claude, den Kontext sofort zu erfassen.

### Standard-Header:
```yaml
---
title: <Titel des Dokuments>
author: Moritz
last_updated: <ISO-Datum>
status: <Draft|Active|Deprecated|Consolidated>
source_id: <ID aus configs.nix oder Architektur-Anforderung>
description: <Kurze Zusammenfassung des Inhalts>
---
```

## ⚙️ Modul-Header (.nix Dateien)

Nix-Module folgen einem standardisierten Interface-Kommentar am Dateianfang, um Abhängigkeiten und Verantwortlichkeiten zu klären.

### Beispiel-Header:
```nix
/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-XXX
 *   title: "<Service Name>"
 *   layer: <00|10|20|90>
 * architecture:
 *   req_refs: [REQ-ID]
 *   upstream: [NIXH-XX-XXX-XXX]
 *   downstream: []
 *   status: audited
 * ---
 */
```

## 🔐 Technical Integrity & Footer

Um Manipulationen vorzubeugen und die Vollständigkeit von Dateiübertragungen (z.B. via SCP oder KI-Output) zu garantieren, werden Dateien mit einem Integritäts-Block abgeschlossen.

### Standard-Footer:
```nix
/**
 * ---
 * technical_integrity:
 *   checksum: sha256:<hash>
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: <Datum>
 *   complexity_score: <1-5>
 * ---
 */
```

## 📁 Maschinenlesbare Konfigurationsdateien

Das System nutzt gezielt strukturierte Formate, um menschliche Fehler zu minimieren:
- **`secrets.yaml`**: SOPS-verschlüsselte Geheimnisse.
- **`.sops.yaml`**: Regelwerk für die Verschlüsselung (Regex-basiert auf Pfaden).
- **`services.yaml`**: Konfiguration des Homepage-Dashboards.
- **`ids-report.json`**: Automatischer Export des Traceability-Systems für externe Tools.

---
*Dokument Ende.*
