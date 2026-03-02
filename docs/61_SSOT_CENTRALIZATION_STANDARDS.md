---
title: SSoT & Defaults System Specification
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Technical Specification
---

# 🎯 SSOT & DEFAULTS SYSTEM

Um die Wartbarkeit des Homelabs zu garantieren, wurde am 02. März 2026 ein striktes **Single Source of Truth (SSoT)** System implementiert. Kein Leaf-Modul darf mehr hartkodierte Systempfade oder globale Einstellungen enthalten.

## 🏗️ Das Defaults-Modul (`00-core/defaults.nix`)

Dieses Modul definiert die globalen Variablen, die über alle Layer hinweg konsistent sein müssen.

### 📁 Dateisystem-Pfade (`my.defaults.paths`)
*   **`statePrefix`**: `/data/state` (Standard-Wurzel für alle App-Datenbanken).
*   **`mediaRoot`**: `/mnt/media` (SSoT für die Medienbibliothek).
*   **`downloadsDir`**: `/mnt/media/downloads` (Staging für Ingress).
*   **`fastPoolRoot`**: `/mnt/fast-pool` (Für NVMe/SSD-Cache und Metadaten).

### 🌍 Lokalisierung & OCR (`my.defaults.locale`)
*   **`timezone`**: `Europe/Berlin` (Wird an alle Container/Dienste vererbt).
*   **`ocr.languages`**: `[ "deu" "eng" ]` (Zentrale Tesseract-Steuerung).
*   **`ocr.outputType`**: `pdfa` (Standard-Format für Archivierung).

## 🔌 Port-Registry (`00-core/ports.nix`)

Alle Dienste folgen dem **10k/20k Schema**, um Kollisionen zu vermeiden und die Firewall-Regeln übersichtlich zu halten.

| Range | Zweck | Beispiele |
| :--- | :--- | :--- |
| **10xxx** | Infrastructure (Layer 10) | AdGuard (10000), Caddy (443), OliveTin (10080) |
| **20xxx** | Services (Layer 20) | Jellyfin (20096), n8n (20017), Sonarr (20989) |

## ⚙️ Hardware-Configs (`00-core/configs.nix`)

Die Master-Config steuert nun dynamisch die Hardware-Fähigkeiten:
*   **`intelGpu = true`**: Aktiviert automatisch QSV und OpenCL-Treiber in allen relevanten Modulen (Jellyfin, Ollama).
*   **`zigbeeStickIP`**: Zentrale IP für den SLZB-06 Koordinator.
*   **`ramGB = 16`**: Berechnet automatisch `max-jobs` für Nix und Cache-Limits für Datenbanken.

## 🔗 Traceability Link
Änderungen an diesen zentralen Werten wirken sich sofort auf alle abhängigen Dienste aus. Bei Refactorings ist dieses System der primäre Ankerpunkt.

---
*Status: ENFORCED*
