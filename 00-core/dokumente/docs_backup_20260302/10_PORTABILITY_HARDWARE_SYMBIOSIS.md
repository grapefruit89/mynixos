---
title: NixOS Homelab Portability & Hardware Symbiosis
project: NMS v2.3
last_updated: 2026-03-02
status: Advanced Architecture Standard
type: Portability Specification
---

# 🌍 PORTABILITY & HARDWARE SYMBIOSIS

Dieses Dokument beschreibt die Strategie, wie das System hardwareunabhängig bleibt und gerätespezifische Anpassungen als "Benutzer-State" behandelt werden.

## 🏗️ Trennung von Logik und Hardware-Profil

Um das System auf mehreren Geräten (Fujitsu Q958, Laptops, Cloud-VMs) einzusetzen, folgt die Architektur dem **Profile-Pattern**:

### 1. Der generische Core (NMS Standard)
Alle Module in `00-core`, `10-infrastructure` und `20-services` sind **hardware-agnostisch**. Sie definieren Dienste und Policies, aber keine Treiber oder Mount-Pfade zu physischen Geräten.

### 2. Hardware als "User-State" (Topf A)
Gerätespezifische Einstellungen werden wie Benutzerpräferenzen behandelt.
- **Speicherort**: `/data/state/hardware-profile.json` oder eine lokale `.nix` Datei, die NICHT im Haupt-Repository versioniert wird (oder via Host-Verzeichnis).
- **Konzept**: Ein Host-System identifiziert sich beim Onboarding und lädt sein spezifisches Profil.

---

## 🔬 Das "Symbiosis" Konzept (Hardware-Detection)

Das Modul `symbiosis.nix` löst das Henne-Ei-Problem der Hardwareerkennung in einem deklarativen System.

### Die Goldene Regel: Bauzeit ≠ Laufzeit
- **Problem**: `builtins.readFile` läuft beim Kompilieren. Wenn sich die Hardware zur Laufzeit ändert (z.B. neue Platte), merkt NixOS das erst beim nächsten `switch`.
- **Lösung**: 
  - Ein Onboarding-Script (`nixhome-detect-hw`) scannt die CPU (Intel/AMD), GPU (QSV/NVENC) und Platten (SSD/HDD).
  - Es schreibt diese Werte in ein lokales State-File.
  - Das System nutzt **Feature-Flags** in `configs.nix`, um Hardware-Optimierungen zu schalten.

---

## 🚀 Portabilitäts-Matrix (Multi-Device)

| Feature | Generische Lösung | Hardware-Spezifisch (State) |
|---|---|---|
| **CPU** | `linuxPackages_latest` | `microcodeIntel = true` |
| **GPU** | `hardware.graphics.enable` | `intel-media-driver` vs. `nvidia` |
| **Storage** | MergerFS Abstraktion | Physische `/dev/disk/by-id/` Pfade |
| **Netzwerk** | `systemd-networkd` | WLAN-Interface Namen (`wlan0`, `wlp2s0`) |

---

## 🛠️ Onboarding für Drittnutzer (GitHub Strategy)

Wenn das System auf GitHub veröffentlicht wird, ist die Portabilität durch folgende Maßnahmen sichergestellt:

1. **Host-Abstraktion**: Neue Nutzer legen lediglich einen Ordner unter `hosts/<ihr-name>/` an.
2. **Minimal-Baseline**: Der Standard-Build kommt ohne aggressive Hardware-Optimierungen aus, um auf jeder x86_64 CPU zu booten (Safety First).
3. **Opt-in Optimierung**: Nutzer aktivieren via `configs.nix` Profile wie `my.profiles.hardware.intel-qsv.enable = true`.

---

## 🔒 Integrität der Hardware-Daten
Hardware-Daten in Topf A (`state`) werden penibel gesichert, da sie die "Physische Identität" des Knotens beschreiben. Ein Verlust dieser Daten würde bei einem Restore auf identischer Hardware zu Performance-Einbußen führen, aber die System-Logik (A-Daten) nicht beschädigen.
