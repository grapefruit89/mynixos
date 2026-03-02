---
title: SRE Rollout Report – March 2026 System Reconstruction
project: NMS v2.3
last_updated: 2026-03-02
status: Completed & Audited
type: Rollout Report
---

# 🚀 MARCH 2026 ROLLOUT SUMMARY

Dieses Dokument dokumentiert die "chirurgische Rekonstruktion" des Systems am 02. März 2026. Ursprünglich als einfacher Rollout geplant, entwickelte sich die Aufgabe aufgrund von massiven Designfehlern in den Vorlagen ("Hausaufgaben") zu einer vollständigen Sanierung der Systemarchitektur.

## 🚨 Die "Doppelkatastrophe"
Beim ersten Boot nach dem Rollout traten zwei kritische Probleme auf:
1.  **TTY-Deadlock**: Ein fehlerhafter SSH-Recovery-Countdown aktualisierte sich sekündlich auf `/dev/tty1`. Dies überschrieb jegliche Benutzereingaben und machte einen lokalen Login am Gerät unmöglich.
2.  **Konfigurations-Chaos**: Die aus dem `/hausaufgaben/`-Ordner übernommenen Dateien enthielten zahlreiche Typfehler, doppelte Attribut-Definitionen und fehlende SSoT-Variablen (`zigbeeStickIP`, `intelGpu`), was zu massiven Build-Abbrüchen führte.

## 🛠️ Durchgeführte Maßnahmen (The Great Cleanup)

### 1. Eliminierung des blockierenden Countdowns
Der TTY-Countdown wurde restlos aus `00-core/ssh-rescue.nix` entfernt. Das System nutzt nun ein passives `sleep 300` im Hintergrund. Der Administrator wird lediglich einmalig im MOTD über das aktive Zeitfenster informiert, ohne den Workflow zu stören.

### 2. Einführung des SSoT-Standards (`00-core/defaults.nix`)
Um hartkodierte Pfade und Werte zu eliminieren, wurde ein neues SSoT-Modul eingeführt:
*   **Zentralisierte Pfade**: `/mnt/media`, `/data/state`, `/mnt/fast-pool` werden nun an einer Stelle definiert.
*   **Global Locales**: Zeitzonen und OCR-Sprachen werden systemweit vererbt.
*   **Port-Registry**: Vollständige Umsetzung des 10k/20k Schemas in `00-core/ports.nix`.

### 3. Modulare Media-Factory (`_servarr-factory.nix`)
Der gesamte Media-Stack wurde auf ein Factory-Pattern umgestellt:
*   Einheitliches Hardening für `sonarr`, `radarr`, `lidarr`, `readarr` und `prowlarr`.
*   Automatische Verzeichnis-Anlage via `systemd.tmpfiles`.
*   Standardisierte GID `169` (media) für alle Dienste.

### 4. Service-Stabilisierung & Debugging
*   **n8n**: Fix des Encryption-Key Mismatch durch Extraktion des Keys aus der bestehenden Datenbank (`gCXaCy...`). Umstellung auf `Environment`-Injection statt fragiler `_FILE` Pointer.
*   **Zigbee**: Durchführung eines Netzwerk-Scans (`nmap`), Identifizierung der neuen Stick-IP (`192.168.2.46`) und Migration auf den modernen **`ember`**-Treiber.
*   **Valkey**: Behebung von Paket-Konflikten im Redis-Modul.

## 📊 System-Status nach Rollout
*   **Failed Units**: 0 (Alle Dienste grün).
*   **Git-Status**: Stand im Branch `main` gesichert (Commit `23ccbb2` + Fixes).
*   **Security-Score**: Deutlich erhöht durch systemweites "Aviation Grade" Hardening.

---
*Status: FINALIZED & SECURED*
