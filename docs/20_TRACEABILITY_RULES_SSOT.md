---
title: NixOS Homelab Traceability Rules & SSoT
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Architecture Specification
---

# 🔗 TRACEABILITY RULES & SSoT

Dieses Dokument präzisiert die Regeln für die Zentralisierung von Werten und die Nutzung des Traceability-Systems.

## 🎯 Shortlist: Werte für configs.nix (SSoT)

Nur Werte, die über mehrere Module hinweg geteilt werden oder personenspezifisch sind, gehören in die `00-core/configs.nix`:

1.  **identity.domain**: Globales Hostname-Pattern (z.B. `m7c5.de`).
2.  **identity.email**: ACME-Kontaktadresse für Zertifikate.
3.  **identity.user**: Primärer interaktiver Benutzer (`moritz`).
4.  **identity.host**: Systemname (`nixhome`).
5.  **network.lanCidrs**: Heimnetz-Bereiche (Trust-Boundary).
6.  **network.tailnetCidrs**: Tailscale-Bereiche (`100.64.0.0/10`).
7.  **network.dnsResolvers**: Bevorzugte System-Resolver (Quad9, Cloudflare).

## 🚫 Local-Only (Keine Zentralisierung nötig)

Werte, die spezifisch für einen Dienst sind, bleiben im jeweiligen Modul:
- `127.0.0.1` / Loopback Bindings.
- Service-interne URLs (sofern kein Cross-Wiring nötig).
- Provider-spezifische WireGuard Endpunkte (gehören in Secrets).

## 📝 Traceability Syntax (Standard)

Um die Herkunft von Werten im Code sichtbar zu machen:
- **Source**: `# source-id: CFG.<gruppe>.<key>` (In `configs.nix`).
- **Sink**: `# sink: CFG.<gruppe>.<key>` (Im Zielmodul).

---
*Dokument Ende.*
