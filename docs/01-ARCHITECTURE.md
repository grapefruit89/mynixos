---
title: Architektur & Hardware
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-ARCH-001
description: Details zur Hardware-Optimierung und der modularen Systemstruktur.
---

# 🏗️ Architektur & Hardware

## 1. Die Hardware (Fujitsu Esprimo Q958)

Das System ist auf Effizienz und Medien-Performance getrimmt.

*   **CPU:** Intel Core i3-9100 (4 Cores / 4 Threads).
*   **Grafik:** Intel UHD 630 (9th Gen).
*   **RAM:** 16GB.
*   **Optimierung:**
    *   **Intel QuickSync:** Vollständig aktiviert für Hardware-Transcoding (Jellyfin).
    *   **GuC/HuC:** Firmware-Loading via Kernel-Parameter `i915.enable_guc=2` aktiv.
    *   **Microcode:** Automatische Sicherheits-Updates für die Intel-CPU.

## 2. Modulare Schichten-Architektur

Die Konfiguration ist in drei logische Ebenen unterteilt, um Ordnung und Portabilität zu gewährleisten:

1.  **00-core (Core):** Das Fundament. Enthält Bootloader, Netzwerk-Basis, User-Management und die zentrale Feature-Registry.
2.  **10-infrastructure:** Plattform-Dienste wie Traefik (Reverse Proxy), Tailscale (VPN) und Wireguard.
3.  **20-services:** Die eigentlichen Anwendungen (Media-Stack, Vaultwarden, n8n, etc.).

## 3. Speicher-Strategie

*   **Kein MergerFS:** Um den HDD-Spindown zu optimieren und die Komplexität gering zu halten, werden Festplatten direkt gemountet.
*   **HD-Idle:** Implementiert für automatischen Spindown von Datengräbern nach 10 Minuten Inaktivität (spart Strom und schont Hardware).
*   **Boot-Partition:** Mit 96MB sehr knapp bemessen. Erfordert regelmäßige Garbage Collection (`nclean`).

## 4. Hardware-Cockpit (`hosts/q958/hardware-profile.nix`)

Alle Hardware-Tweaks sind in einem Profil gebündelt und können über die Registry ein- oder ausgeschaltet werden. Dies ermöglicht es, die Konfiguration einfach auf andere Hardware zu portieren.
