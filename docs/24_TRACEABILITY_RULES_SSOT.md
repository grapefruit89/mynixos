---
title: NixOS Homelab Traceability Rules & SSoT
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Architecture Specification
---

# 🔗 TRACEABILITY RULES & SSoT

Dieses Dokument präzisiert die Regeln für die Zentralisierung von Werten und die Nutzung des Traceability-Systems.

## 📐 Modul-Konventionen (Wartbarkeit)

Jedes `.nix` Modul MUSS folgendem Aufbau folgen:

### 1. Metadaten-Header
Ein Header als Kommentar am Dateianfang für schnelles Onboarding:
```nix
# meta:
#   owner: core|infra|media|apps|policy
#   status: active|draft|placeholder
#   summary: Kurzbeschreibung
```

### 2. Standard-Reihenfolge
1. `let` Blöcke.
2. `options` (Eigene Optionen unter `my.<domain>.<name>`).
3. `config` (mit `mkIf` Gates).
4. `assertions` (Frühzeitige Fehlerprüfung).

## 🎯 Shortlist: Werte für configs.nix (SSoT)

Nur Werte mit hohem "Fan-out" (Verwendung in >2 Dateien) gehören in die `configs.nix`:
- `identity.domain`, `identity.user`, `identity.host`.
- `network.lanCidrs`, `network.tailnetCidrs`.
- `network.dnsResolvers`.

## 📝 Traceability Syntax

- **Source**: `# source-id: CFG.<gruppe>.<key>`
- **Sink**: `# sink: CFG.<gruppe>.<key>`
- **Spec-IDs**: Sicherheitskritische Regeln erhalten IDs (z.B. `[SEC-SSH-001]`), die in Code und Doku (`90-policy/spec-registry.md`) synchron gehalten werden.
