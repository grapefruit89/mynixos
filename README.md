# 🚀 Fujitsu Esprimo Q958 | NixOS Homelab

<p align="center">
  <a href="#de"><img src="https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/de.svg" width="30px"> **Deutsch**</a> | 
  <a href="#en"><img src="https://raw.githubusercontent.com/lipis/flag-icons/main/flags/4x3/us.svg" width="30px"> **English**</a>
</p>

---

<a name="de"></a>
## 🇩🇪 Deutsch

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Hardware](https://img.shields.io/badge/Hardware-Fujitsu%20Q958-orange.svg?style=flat-square)](https://www.fujitsu.com)

Willkommen in der Schaltzentrale meines Homelabs. Dieses Repository enthält die vollständige, deklarative Konfiguration für einen hochoptimierten **Fujitsu Esprimo Q958** Homeserver.

### 🏗️ System-Philosophie

Dieses Projekt folgt strengen Prinzipien, um maximale Stabilität und Performance zu erreichen:

*   **Modulare Layer:** Strikt getrennte Ebenen für das Fundament (`00-core`), die Plattform (`10-infrastructure`) und die Anwendungen (`20-services`).
*   **Hardware-Optimierung:** Volle Ausnutzung der Intel Core i3-9100 CPU und der UHD 630 Grafik via QuickSync (GuC/HuC Firmware) für effizientes Media-Transcoding.
*   **KISS & Vanilla:** Wir nutzen Standard-NixOS-Optionen statt komplexer Abstraktionen. Das System ist bewusst **ohne Flakes** aufgebaut (Nix-Channel-basiert), aber vollständig für eine zukünftige Umstellung vorbereitet.
*   **Sicherheits-Fokus:** Ein nativer NFTables-Killswitch für VPN-Dienste, gehärtete SSH-Konfiguration und systemd-Sandboxing für alle Services.

### 📚 Dokumentation (Das Handbuch)

Das Herzstück dieses Repos ist unsere strukturierte Bibliothek. Hier erfährst du alles, was du wissen musst:

👉 **[ZUM HANDBUCH INDEX](./bibliothek/Handbuch_Index.md)**

*   [🏗️ **01 Architektur & Hardware**](./bibliothek/01_Architektur.md) – Hardware-Specs, GPU-Beschleunigung und HDD-Spindown Strategie.
*   [🛠️ **02 Betrieb & Workflow**](./bibliothek/02_Betrieb.md) – Der tägliche Umgang, Aliase (`nsw`, `ntest`), das Dashboard (MOTD) und Wartung.
*   [🛡️ **03 Services & Sicherheit**](./bibliothek/03_Services_Sicherheit.md) – Das 10k/20k Port-Register, Traefik-Setup und Sicherheits-Leitplanken.
*   [💡 **04 Roadmap & Zukunft**](./bibliothek/04-ROADMAP.md) – Geplante Features wie Fastfetch-MOTD und automatisierte Backups.

---

<a name="en"></a>
## 🇺🇸 English

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Hardware](https://img.shields.io/badge/Hardware-Fujitsu%20Q958-orange.svg?style=flat-square)](https://www.fujitsu.com)

Welcome to my Homelab control center. This repository contains the full, declarative configuration for a highly optimized **Fujitsu Esprimo Q958** home server.

### 🏗️ System Philosophy

This project adheres to strict architectural principles to ensure stability and high performance:

*   **Modular Layers:** Clear separation between the foundation (`00-core`), platform infrastructure (`10-infrastructure`), and end-user services (`20-services`).
*   **Hardware-First:** Full utilization of the Intel Core i3-9100 CPU and UHD 630 Graphics via QuickSync (utilizing GuC/HuC firmware) for efficient media transcoding.
*   **KISS & Vanilla:** We prioritize standard NixOS options over complex abstractions. The system intentionally avoids active **Flakes** for simplicity (using nix-channels) but remains fully "Flake-ready".
*   **Security-Centric:** Featuring a native NFTables-based VPN killswitch, hardened SSH access, and systemd-sandboxing for almost all active services.

### 📚 Documentation (The Handbook)

The core of our knowledge sharing is the structured library. Explore the details here:

👉 **[TO HANDBOOK INDEX](./bibliothek/Handbuch_Index.md)**

*   [🏗️ **01 Architecture & Hardware**](./bibliothek/01_Architektur.md) – Hardware specs, GPU power, and HDD spindown strategy.
*   [🛠️ **02 Operations & Workflow**](./bibliothek/02_Betrieb.md) – Daily operation guide, aliases (`nsw`, `ntest`), the dashboard (MOTD), and maintenance.
*   [🛡️ **03 Services & Security**](./bibliothek/03_Services_Sicherheit.md) – The 10k/20k Port Registry, Traefik setup, and security guardrails.
*   [💡 **04 Backlog & Ideas**](./bibliothek/04-ROADMAP.md) – Future plans like Fastfetch-MOTD and automated backups.
5. [🏠 **Home-Manager Guide**](./bibliothek/05_Home_Manager.md)
6. [💎 **Inspirationen & Best Practices**](./bibliothek/Inspirationen_aus_der_Reposammlung.md)

---
*Created with ❤️ by Moritz & AI.*
