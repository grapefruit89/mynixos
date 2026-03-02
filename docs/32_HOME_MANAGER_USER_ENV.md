---
title: NixOS Homelab Home-Manager & User Environment
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Enriched)
type: User Documentation
---

# 🏠 HOME-MANAGER & USER ENVIRONMENT

Während NixOS das System verwaltet, kümmert sich Home-Manager um die Identität (`/home/moritz`).

## 📂 Struktur
- Pfad: `/etc/nixos/users/moritz/home.nix`.
- Inhalt: User-Pakete (`micro`, `ncdu`), Dotfiles und persönliche Shell-Aliase.

> **[NixOS Expert-Einschub: Home-Manager Standalone vs. Module]**
> Wir nutzen Home-Manager als **NixOS-Modul** (`home-manager.users.moritz`).
> **Vorteil**: Die User-Config wird beim `nixos-rebuild switch` synchron mit dem System aktualisiert. Es gibt keinen "Version-Mismatch" zwischen System-Packages und User-Settings.

## 🚀 Portabilitäts-Konzept
Um das Setup auf neue Hardware zu bringen:
1. `users/<name>/home.nix` anlegen.
2. `identity.user` in `configs.nix` anpassen.

> **[NixOS Expert-Einschub: Ephemeral Home Maintenance]**
> Falls du auf ein **tmpfs-root (Holy State)** umsteigst, ist die Persistenz des User-Ordners kritisch.
> **Lösung**: Nutze das `impermanence` Home-Manager Modul. Es erlaubt dir, gezielt nur Ordner wie `.ssh`, `.gnupg` und `.local/share/zoxide` zu persistieren, während der restliche Müll bei jedem Reboot gelöscht wird. Dies verhindert das "Zusmüllen" deines Home-Ordners über die Jahre.
