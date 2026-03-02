---
title: Replicating Nixarr Logic (Non-Flake Guide)
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Technical Deep-Dive
---

# 🏗️ REPLICATING NIXARR LOGIC WITHOUT FLAKES

Du kannst die komplette Logik von **Nixarr** auch in deinem "Standard" NixOS (ohne Flakes) nachbauen. Das Rad muss nicht neu erfunden werden, nur weil wir keine Flakes nutzen.

## 1. Das VPN-Namespace Pattern (Confinement)
Nixarr nutzt Netzwerk-Namespaces, um Downloads physisch zu isolieren.
- **Vorteil**: Ein Dienst sieht *nur* das VPN-Interface.
- **Nachbau**: Wir nutzen das `vpn-confinement.nix` Modul (was du bereits vorbereitet hast). Du fügst einfach `vpnConfinement = { enable = true; ... };` zu den systemd-Services hinzu.

## 2. Automatisierte API-Verkabelung
Nixarr liest API-Keys aus Dateien.
- **Logik**: Ein Bash-Skript nutzt `xq` (XML Query) oder `jq` (JSON Query), um den Key aus `/var/lib/sonarr/config.xml` zu ziehen.
- **SRE-Weg**: Wir integrieren dies in unseren `arr-wire.service`.

## 3. Die perfekte Ordnerstruktur
Die haben wir bereits in deiner `storage.nix` umgesetzt. Das ist 1:1 die Nixarr-Logik, optimiert für dein ABC-Tiering.

---

# 🤖 GEMINI CLI EXTENSIONS (SRE PLUGINS)

Für deine aktuelle Gemini CLI gibt es mächtige Erweiterungen, die perfekt zu deinem Projekt passen:

| Plugin | Funktion | Warum für dich? |
|---|---|---|
| **Conductor** | Planungs-Agent | Hilft dir, komplexe Features erst zu planen, bevor ich Code schreibe. |
| **Jules** | Refactoring-Agent | Ideal zum automatisierten Aufräumen von alten .nix Files. |
| **Security** | Schwachstellen-Scan | Prüft deine Nix-Config auf unsichere Defaults. |

> **Tipp**: Du kannst diese Erweiterungen via `gemini extensions install <URL>` hinzufügen. Sie machen aus dieser CLI ein echtes SRE-Cockpit.
