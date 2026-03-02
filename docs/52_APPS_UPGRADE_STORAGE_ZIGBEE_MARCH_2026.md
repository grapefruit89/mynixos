---
title: Apps Upgrade: Storage & Zigbee - March 2026
project: NMS v2.3
last_updated: 2026-03-02
status: Implementation Complete
type: Change Log & History
---

# 🚀 APPS UPGRADE: STORAGE & ZIGBEE (MARCH 2026)

Dieses Dokument hält den Umbau der App-Infrastruktur und die Integration des neuen Zigbee-Stacks fest.

## 📁 Storage Path Refactoring
- **Nixarr Standard**: Die Ordnerstruktur wurde vollständig auf das Nixarr-Schema umgestellt.
- **ABC-Alignment**: 
  - Downloads (Tier B) -> `/mnt/fast-pool/downloads`
  - Bibliotheken (Tier C) -> `/mnt/media/`
- **Group Media (GID 169)**: Einführung der globalen Mediengruppe für alle relevanten Dienste.
- **Setgid Enforcement**: Alle Medienordner erzwingen nun die Gruppen-Zugehörigkeit.

## 🏠 Home Assistant & Zigbee
- **Zigbee Stack**: Einführung von **Mosquitto** (MQTT) und **Zigbee2MQTT** als entkoppelte Dienste.
- **Ethernet Coordinator**: Native TCP-Anbindung für den **SLZB-06** Stick.
- **Lovelace YAML**: Umstellung des HA-Frontends auf Code-Basis für 100% Reproduzierbarkeit.

## 🔐 Secrets Centralization
- **Refactoring**: Umstellung der `secrets.nix` auf eine logische Hierarchie.
- **Identity/Infra/Apps**: Klare Trennung der Zuständigkeiten innerhalb der Sops-Verschlüsselung.
