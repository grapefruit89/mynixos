---
title: 02_Betrieb
category: Architektur
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: 9a283828d3398bae642b21aa2469daf864a3c2efa2878b8130e8b0801670be37
---
---
title: Betrieb & Workflow
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-OPS-001
description: Anleitung für den täglichen Betrieb, Aliase und Systempflege.
---

# 🛠️ Betrieb & Workflow

## 1. Der "Daily Driver" Workflow

Änderungen am System folgen immer diesem Muster:

1.  **Navigieren:** `ncfg` (Wechselt nach `/etc/nixos`).
2.  **Editieren:** Datei mit Editor deiner Wahl bearbeiten.
3.  **Testen:** `ntest` (Führt `nixos-rebuild test` aus – aktiv bis zum Reboot).
4.  **Aktivieren:** `nsw` (Führt `nixos-rebuild switch` aus – macht die Änderungen persistent).
5.  **Speichern:** `git add -A && git commit -m "..." && git push`.

## 2. Zentrale Aliase (Shortcuts)

Für maximale Effizienz wurden folgende Befehle für den User `moritz` eingerichtet:

| Befehl | Entspricht | Zweck |
| :--- | :--- | :--- |
| `ncfg` | `cd /etc/nixos` | Schneller Zugriff auf die Config. |
| `nsw` | `sudo nixos-rebuild switch` | Dauerhafte Aktivierung. |
| `ntest` | `sudo nixos-rebuild test` | Temporärer Test. |
| `ndry` | `sudo nixos-rebuild dry-run` | Simulation ohne Änderungen. |
| `ngit` | `git status -sb` | Schneller Git-Überblick. |
| `nclean` | GC + Delete Generations | Schaufelt Platz auf `/boot` frei. |
| `nix-deploy` | Custom Script | Automatisierter Build + Git Sync. |

## 3. Das Dashboard (MOTD)

Beim Login via SSH (oder lokal) begrüßt dich ein dynamisches Dashboard. Es zeigt:
*   Hostname und IP-Adressen (LAN & Tailscale).
*   Systemlast, Disk-Usage und RAM-Verbrauch.
*   **Service-Status:** Den aktuellen Zustand von Traefik, SSH, Tailscale und Jellyfin.
*   Eine Erinnerung an die wichtigsten Aliase.

## 4. Feature-Registry (`00-core/configs.nix`)

Die `configs.nix` ist dein zentrales Cockpit. Hier werden systemweite Variablen gesteuert:
*   **Bastelmodus:** Schaltet die Firewall aus und erlaubt passwortloses Sudo.
*   **Hardware-Toggles:** Aktiviert/Deaktiviert GPU-Optimierungen.
*   **Identity:** Definiert Domain, Email und Admin-User.
