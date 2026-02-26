---
title: Handbuch Index / Handbook Index
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-IDX-001
description: Zentrale Wissensbasis für das Fujitsu Q958 NixOS Homelab.
---

# 📖 Das Homelab Handbuch / The Homelab Handbook

<p align="center">
  <a href="#de"><img src="https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/de.svg" width="30px"> **Deutsch**</a> | 
  <a href="#en"><img src="https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/us.svg" width="30px"> **English**</a>
</p>

---

<a name="de"></a>
## 🇩🇪 Inhaltsverzeichnis (DE)

### [01 — Architektur & Hardware](./01_Architektur.md)
> Wie ist der Server aufgebaut?
*   **Hardware:** Details zum Fujitsu Q958 & i3-9100.
*   **Grafik:** Konfiguration von Intel QuickSync (iHD, GuC/HuC).
*   **Layer:** Erklärung der Schichten-Struktur (00/10/20).
*   **Speicher:** HDD Spindown (HD-Idle) und Boot-Partition Management.

### [02 — Betrieb & Workflow](./02_Betrieb.md)
> Wie bediene ich das System im Alltag?
*   **Zyklus:** Änderungen editieren, mit `ntest` prüfen und per `nsw` aktivieren.
*   **Aliase:** Alle Shortcuts für Git, Nix und System-Wartung.
*   **Dashboard:** Das MOTD-Dashboard beim Login verstehen.
*   **Platzmangel:** Rettungsanker für volle `/boot`-Partitionen.

### [03 — Services & Sicherheit](./03_Services_Sicherheit.md)
> Welche Dienste laufen und wie sind sie abgesichert?
*   **Ports:** Das konsistente 10k/20k Port-Register.
*   **Edge:** Traefik Reverse-Proxy mit ACME (LetsEncrypt).
*   **VPN:** Der NFTables Killswitch für den Media-Stack.
*   **Härtung:** SSH-Schutz und Systemd Sandboxing.

### [04 — Roadmap & Zukunft](./04-ROADMAP.md)
> Wohin geht die Reise?
*   Zukünftige Projekte (Monitoring, Backups, Fastfetch).

---

<a name="en"></a>
## 🇺🇸 Table of Contents (EN)

### [01 — Architecture & Hardware](./01_Architektur.md)
> How is the server built?
*   **Hardware:** Deep dive into Fujitsu Q958 & i3-9100 specs.
*   **Graphics:** Configuring Intel QuickSync (iHD, GuC/HuC).
*   **Layering:** Understanding the 00/10/20 structure.
*   **Storage:** HDD Spindown (HD-Idle) and Boot partition management.

### [02 — Operations & Workflow](./02_Betrieb.md)
> How do I manage the system day-to-day?
*   **The Cycle:** Edit changes, test with `ntest`, and persist with `nsw`.
*   **Aliases:** Comprehensive list of shortcuts for Git, Nix, and maintenance.
*   **Dashboard:** Understanding the MOTD system info on login.
*   **Space:** Survival guide for full `/boot` partitions.

### [03 — Services & Security](./03_Services_Sicherheit.md)
> Which services are active and how are they secured?
*   **Ports:** The consistent 10k/20k Port Registry.
*   **Edge:** Traefik Reverse-Proxy with ACME (LetsEncrypt).
*   **VPN:** The NFTables Killswitch for the media stack.
*   **Hardening:** SSH protection and Systemd Sandboxing.

### [04 — Backlog & Ideas](./04-ROADMAP.md)
5. [🏠 **Home-Manager Guide**](./05_Home_Manager.md) - Eigene Dotfiles & Portabilität.
6. [💎 **Inspirationen & Best Practices**](./Inspirationen_aus_der_Reposammlung.md) - Analyse der Profi-Repos.
> What's on the horizon?
*   Future roadmap (Monitoring, Backups, Fastfetch).

---
👉 [**AI_CONTEXT.md**](./AI_CONTEXT.md)
