---
title: KI Kontext & Direktiven
author: Moritz
last_updated: 2026-02-26
status: active
source_id: AI-CTX-001
description: Grundlegende Regeln für Large Language Models (LLMs) bei der Arbeit an diesem Repo.
---

# 🤖 AI_CONTEXT.md

Dieses Dokument dient als Einstiegspunkt für jede KI, die an dieser Konfiguration arbeitet.

## 1. Repository-Struktur

*   **Nix-Code:** Befindet sich modular unter `/etc/nixos/`.
*   **Dokumentation:** Liegt strikt unter `docs/`. Nutze die `source_id`s in den Dateien für Deep-Dives.
*   **Backlog & Ideen:** Siehe `docs/04-BACKLOG-AND-IDEAS.md`.

## 2. Strikte Regeln (The Golden Rules)

1.  **Keine Flakes (aktuell):** Nutze Standard `nix-channel` Logik. Die Struktur muss aber "Flake-ready" sein.
2.  **Schichten-Architektur:** Beachte die Layer (00-system, 10-infrastructure, 20-services).
3.  **Vanilla vor Abstraktion:** Bevorzuge Standard-NixOS Optionen gegenüber komplexen Wrappern (KISS-Prinzip).
4.  **Single Source of Truth:** Alle IPs, Ports und Hardware-Toggles müssen über `00-core/configs.nix` oder `00-core/ports.nix` laufen. Keine harten Werte in den Modulen!
5.  **Security First:** Nutze systemd-Härtung für jeden neuen Dienst und beachte den NFTables-Killswitch.
6.  **Sprache:** Erklärungen und Kommentare immer auf **DEUTSCH**.

## 3. Wissens-IDs (Traceability)

Dieses Repository nutzt `source-id` und `sink` Kommentare. Wenn du Code änderst, stelle sicher, dass die Verbindung zwischen Definition (`source-id`) und Verwendung (`sink`) erhalten bleibt.
