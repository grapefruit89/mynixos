---
title: Home-Manager Guide
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-HM-001
description: Anleitung zur Verwaltung persönlicher User-Konfigurationen.
---

# 🏠 Home-Manager (Persönliche Einstellungen)

Home-Manager ist das Werkzeug, mit dem wir deine persönliche Umgebung (`/home/moritz`) verwalten. Während NixOS das *System* konfiguriert, kümmert sich Home-Manager um deine *Heimat*.

## 📂 Wo liegen die Dateien?

Deine persönlichen Einstellungen befinden sich unter:
👉 **`/etc/nixos/users/moritz/home.nix`**

## 🛠️ Was wird hier verwaltet?

1.  **Pakete:** Tools, die nur du als User brauchst (z.B. `micro`, `ncdu`).
2.  **Dotfiles:** Konfigurationen für deine Shell (`.bashrc`), Editoren und mehr.
3.  **Aliase:** Deine ganz persönlichen Shortcuts.

## 🚀 Portabilität & Umzug

Wenn du dieses Repository auf einem anderen Rechner nutzen willst:
1.  Lege einen neuen Ordner unter `/etc/nixos/users/<dein-name>/` an.
2.  Kopiere eine bestehende `home.nix` dort hinein.
3.  Ändere in der `00-core/configs.nix` den Wert `identity.user` auf deinen Namen.
4.  Beim nächsten `nsw` wird deine Umgebung automatisch erzeugt.

---
👉 [**Handbuch Index**](./Handbuch_Index.md)
