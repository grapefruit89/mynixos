---
title: NixOS Homelab Architecture & Recovery Deep-Dive
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Enriched)
type: Technical Deep-Dive
---

# 🏗️ ARCHITECTURE & RECOVERY DEEP-DIVE

Dieses Dokument bündelt das Wissen über die Hardware-Optimierung, die Schichten-Architektur und die operativen Workflows.

## 💻 Hardware-Spezifika (Fujitsu Q958)
- **CPU/GPU**: Intel i3-9100 mit UHD 630.
- **Kernel-Tweaks**: `i915.enable_guc=2` für GuC/HuC Firmware-Loading (Pflicht für performantes QuickSync).
- **Microcode**: Automatisierte Updates sind Teil des `hardware-profile.nix`.

> **[NixOS Expert-Einschub: UHD 630 Transcoding Power]**
> Messungen aus der Community (2025/2026) bestätigen: Mit korrektem iHD-Treiber (`intel-media-driver`) schafft die UHD 630 einen **4K HEVC -> 1080p H.264 Stream bei ca. 5% CPU-Last**. Ohne Hardware-Beschleunigung läge die Last bei ~100% auf allen 4 Kernen.
> **Tipp**: `hardware.graphics.extraPackages = [ pkgs.vpl-gpu-rt ];` hinzufügen, um modernste OneVPL (QSV) Funktionen für neuere Apps freizuschalten.

## 📂 Die 3-Schichten-Philosophie
1. **00-core**: Das Fundament (Boot, Netz, User, Registry).
2. **10-infrastructure**: Die Plattform (Caddy, Tailscale, Wireguard).
3. **20-services**: Die Applikationen (Media, Apps).

## 🛠️ Der "Daily Driver" Workflow (Optimiert)
Um die Stabilität zu gewährleisten, wurde ein fester Zyklus etabliert:
1. `ncfg`: Wechsel in das Konfigurationsverzeichnis.
2. Editieren der Dateien.
3. `ntest`: Temporärer Test (`nixos-rebuild test`).
4. `nsw`: Permanente Aktivierung (`nixos-rebuild switch`).
5. `nclean`: Freischaufeln der knappen `/boot`-Partition (96MB Limit).

> **[NixOS Expert-Einschub: Projekt-Isolation mit direnv]**
> Ersetze manuelle Paket-Installationen für Skripte durch `direnv`.
> **Implementation**: `programs.direnv.nix-direnv.enable = true;` im Home-Manager. In jedem Projektordner eine `.envrc` mit `use nix` oder `use flake` anlegen. Dies hält die globale User-Umgebung sauber und lädt Abhängigkeiten (wie `ffmpeg` oder `git`) nur bei Bedarf im Terminal-Tab.

## 📺 Das MOTD Dashboard
Beim Login zeigt das System ein dynamisches Status-Tableau.
> **[NixOS Expert-Einschub: Modern MOTD with Fastfetch]**
> Statt eines statischen Scripts wird für 2026 der Umstieg auf `fastfetch` empfohlen. Es bietet eine wesentlich performantere JSON-Ausgabe von Systemdaten und kann über eine zentrale Config (`~/.config/fastfetch/config.jsonc`) das 10k/20k Port-Register direkt einblenden.
