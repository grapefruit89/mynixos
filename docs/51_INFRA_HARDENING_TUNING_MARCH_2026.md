---
title: Infrastructure Hardening & Tuning - March 2026
project: NMS v2.3
last_updated: 2026-03-02
status: Analysis & Implementation Complete
type: Change Log & History
---

# 🏗️ INFRASTRUCTURE HARDENING & TUNING (MARCH 2026)

Dieses Dokument hält die Optimierungen am Infrastructure-Layer (10) fest, basierend auf SRE-Best-Practices und der "Binary-First" Policy.

## 🗄️ PostgreSQL Performance & Safety
- **Tuning**: Optimierung der Speicherparameter (`shared_buffers: 1GB`, `effective_cache_size: 3GB`) für 16GB RAM.
- **Backups**: Implementierung von `services.postgresqlBackup` für tägliche SQL-Dumps (01:30 Uhr).
- **Isolation**: Systemd-Sandboxing (`ProtectSystem=strict`, `SystemCallFilter`) aus nixpkgs übernommen.

> **[NixOS Expert-Einschub: PostgreSQL WAL Management]**
> Mit `max_wal_size = "4GB"` verhindern wir häufige Checkpoints, die Schreiblast auf der SSD verursachen. Für ein Homelab ist dies die ideale Balance zwischen Crash-Recovery-Zeit und Hardware-Schonung.

## 🛡️ AdGuard Home DNS-Turbo
- **Performance**: Cache auf 32MB erhöht, `fastest_addr=true` für minimale Latenz aktiviert.
- **Reproduzierbarkeit**: Voll-deklarative DNS-Rewrites im Nix-Code statt manueller UI-Einträge.

## 🛡️ ClamAV Resource Guard
- **CPU-Schutz**: Scans sind auf 2 Kerne limitiert und laufen mit `idle` Priorität.
- **Automatisierung**: Wöchentlicher Full-Scan (Samstag 03:00 Uhr).

## ⛔ No-Local-Build Policy (Nix Tuning)
- **Implementation**: `require-substitutes = true`. Das System verweigert lokales Kompilieren ohne expliziten manuellen Override.
- **Timeout**: Harter Abbruch nach 30 Minuten Bauzeit zum Schutz der Ressourcen.

> **[NixOS Expert-Einschub: Store Auto-Optimization]**
> `auto-optimise-store = true` ersetzt identische Dateien im Nix-Store durch Hardlinks. Bei großen Setups spart dies oft 5-15% des SSD-Platzes ein, ohne die Performance zu beeinträchtigen.
