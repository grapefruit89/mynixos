---
title: SRE Upgrade Report - March 2026
project: NMS v2.3
last_updated: 2026-03-02
status: Implementation Complete (AI Enriched)
type: Change Log & History
---

# 🚀 SRE UPGRADE REPORT (MARCH 2026)

Dieses Dokument hält den technologischen Sprung fest, der durch den Abgleich mit den offiziellen `nixpkgs` Standards vollzogen wurde.

## 💾 Storage & Boot Evolution
- **ESP-Upgrade**: Die Boot-Partition wurde auf **1000MB** erweitert.
- **Konfiguration**: Das `configurationLimit` wurde von 2 auf **15** erhöht.
- **Sicherheit**: Der Boot-Editor wurde deaktiviert (`editor = false`).

> **[NixOS Expert-Einschub: Boot-Strategie für 1GB ESP]**
> Mit einer 1000MB Partition bist du nun bereit für das **Lanzaboote (Secure Boot)** Upgrade. UKIs (Unified Kernel Images) benötigen viel Platz, da sie Kernel und Initrd bündeln. Die 1GB Grenze erlaubt ca. 10-15 parallele UKIs, was für ein sicheres Homelab perfekt ist.
> **Tipp**: Falls du später auf 50+ Generationen gehen willst, solltest du auf das **XBOOTLDR-Pattern** umsteigen, bei dem nur der aktuelle Loader auf dem ESP liegt und alle Kernel-Images auf einer separaten `/boot` Partition.

## 🧠 RAM-Logging (Aviation Grade)
- **Konzept**: Umstellung auf `Storage=volatile`.
- **Spezifikation**: 500MB RAM, 100MB Chunks, 5 Tage Vorhaltung.

> **[NixOS Expert-Einschub: Volatile Log Analysis]**
> Da RAM-Logs flüchtig sind, empfiehlt sich für 2026 das Tool **nixos-logwatch** oder die Integration von **Promtail**, um kritische Fehler (Severity < 3) kurz vor einem Reboot verschlüsselt an einen kleinen Cloud-Bucket zu senden. So bleiben "Todes-Logs" nach einem harten Crash erhalten, ohne die lokale SSD im Alltag zu stressen.

## 🛡️ Service-Härtung (Highlights)
- **Jellyfin**: Deklarative `encoding.xml` für Q958 (QSV).
- **Vaultwarden**: Null-Privilegien Sandbox.
- **Caddy**: UDP/QUIC Tuning.

> **[NixOS Expert-Einschub: systemd-analyze security]**
> Nach diesem Upgrade erreicht dein System in `systemd-analyze security` Spitzenwerte. Die Kombination aus `ProtectProc=invisible` und `SystemCallFilter` isoliert deine Dienste so stark, dass sie physisch keinen Zugriff mehr auf den Nix-Store oder andere Service-Namespaces haben. Dies minimiert die Angriffsfläche bei Zero-Day Exploits massiv.

## ⛔ No-Local-Build Policy
- **Implementation**: `require-substitutes = true` und 30min Timeout.

> **[NixOS Expert-Einschub: Binary Cache Failover]**
> Um zu verhindern, dass ein Ausfall von `cache.nixos.org` dein System blockiert, sollte man in SRE-Umgebungen einen **lokalen Pull-Through-Cache (z.B. mit Harmonia)** betreiben. Dieser speichert einmal heruntergeladene Binaries lokal im LAN und dient als "Offline-Versicherung", falls dein Internet oder der offizielle Cache streikt.

## 🔗 Traceability
Alle geänderten Dateien referenzieren nun direkt die offiziellen `nixpkgs` Quellen.
