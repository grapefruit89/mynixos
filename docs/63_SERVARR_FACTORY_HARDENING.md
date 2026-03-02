---
title: Servarr Factory & Media Hardening Pattern
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Architecture Pattern
---

# 🎬 SERVARR FACTORY & HARDENING

Zur Skalierung des Media-Stacks wurde eine zentrale Factory-Logik eingeführt. Dies verhindert "Configuration Drift" und garantiert, dass alle Dienste denselben hohen Sicherheitsstandards folgen.

## 🏗️ Das Factory-Modul (`20-services/media/_servarr-factory.nix`)

Dieses Modul bietet standardisierte Funktionen für alle "Arr"-Dienste (Sonarr, Radarr, etc.).

### 1. mkServarrHardening (Aviation Grade)
Enthält ein aggressives Sandboxing-Set:
*   `CapabilityBoundingSet = ""`: Keine privilegierten Kernel-Calls.
*   `ProtectProc = "invisible"`: Der Dienst sieht keine anderen Prozesse im System.
*   `RestrictAddressFamilies`: Nur `AF_INET`, `AF_INET6` und `AF_UNIX` erlaubt.
*   `SystemCallFilter = [ "@system-service" "~@privileged" ]`.

### 2. mkServarrTmpfiles
Automatisiert die Anlage der Verzeichnisse mit korrekten Berechtigungen:
*   State-Ordner werden mit `0700` angelegt.
*   Geteilte Medien-Ordner erhalten die GID `169` (media).

## 🚀 Implementierungs-Beispiel (`sonarr.nix`)

Dienste nutzen nun die Factory, um Redundanz zu vermeiden:
```nix
serviceConfig = {
  ExecStart = "...";
  ReadWritePaths = [ cfg.stateDir defs.paths.mediaRoot ];
} // factory.mkServarrHardening;
```

## 📂 Speicher-Tiering (ABC-Standard)
Die Factory erzwingt die Trennung der Datenströme:
*   **Tier A (NVMe)**: Konfigurationen & Datenbanken (`/data/state`).
*   **Tier B (SATA SSD)**: Metadaten & Covers (`/mnt/fast-pool/metadata`).
*   **Tier C (HDD)**: Die eigentliche Medienbibliothek (`/mnt/media`).

Dank des Factory-Patterns werden Bind-Mounts für Covers (`MediaCover`) nun automatisch auf die SSD umgeleitet, um die System-Performance zu maximieren.

---
*Status: STANDARDIZED*
