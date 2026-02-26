---
title: Handbuch Index
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-IDX-001
description: Zentrales Inhaltsverzeichnis für das Fujitsu Q958 NixOS Homelab Handbuch.
---

# 📖 Das Homelab Handbuch

Dieses Handbuch ist die "Single Source of Truth" für den Betrieb und die Weiterentwicklung dieses Servers. Es ist so strukturiert, dass sowohl Menschen als auch KI-Assistenten sofort verstehen, wie das System funktioniert.

## 🗺️ Inhaltsverzeichnis

### [01 — Architektur & Hardware](./01_Architektur.md)
> Wie ist der Server aufgebaut? Welche Hardware steckt drin?
- Hardware-Spezifikationen (Fujitsu Q958, i3-9100).
- Grafik-Optimierung (QuickSync, GuC/HuC).
- Die 3-Schichten-Architektur (system, infrastructure, services).
- Speicherstrategie (Direkt-Mounts & HD-Idle).

### [02 — Betrieb & Workflow](./02_Betrieb.md)
> Wie bediene ich das System im Alltag?
- Der "Edit-Test-Switch" Zyklus.
- Übersicht der Shell-Aliase.
- Das Dashboard (MOTD) erklärt.
- Wartung & Platzmanagement (/boot Rettung).

### [03 — Services & Sicherheit](./03_Services_Sicherheit.md)
> Welche Dienste laufen hier und wie sicher sind sie?
- Zentrale Port-Registry (Das 10k/20k Schema).
- Traefik Reverse Proxy & ACME.
- NFTables VPN Killswitch.
- SSH Hardening & Systemd Sandboxing.

### [04 — Backlog & Ideen](./04_Backlog_Ideen.md)
> Wo geht die Reise hin?
- Geplante Features (Fastfetch, Monitoring, Backups).
- Technische Schulden & Refactoring-Ziele.

---

## 🤖 Für KI-Assistenten
Bitte lies zuerst den [**AI_CONTEXT.md**](./AI_CONTEXT.md), bevor du Änderungen an der Codebasis vornimmst. Er enthält die "Goldenen Regeln" dieses Repositories.
