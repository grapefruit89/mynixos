# 🚀 Fujitsu Esprimo Q958 | NixOS Homelab

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Hardware](https://img.shields.io/badge/Hardware-Fujitsu%20Q958-orange.svg?style=flat-square)](https://www.fujitsu.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

Willkommen in der Schaltzentrale meines Homelabs. Dieses Repository enthält die vollständige, deklarative Konfiguration für einen hochoptimierten **Fujitsu Esprimo Q958** Homeserver.

---

## 🏗️ System-Philosophie

Dieses Projekt folgt strengen architekthischen Prinzipien, um Stabilität und Wartbarkeit zu garantieren:

- **Modulare Layer:** Klare Trennung zwischen System-Basis (`00-core`), Infrastruktur (`10-infrastructure`) und Diensten (`20-services`).
- **Hardware-First:** Tiefe Integration von Intel QuickSync (UHD 630) für Medien-Workloads.
- **KISS & Vanilla:** Fokus auf Standard-NixOS-Optionen. Derzeit bewusst **ohne Flakes**, um Komplexität zu reduzieren, aber vollständig "Flake-ready" vorbereitet.
- **Security-Aware:** NFTables-basierter Killswitch für VPN-Dienste und gehärteter SSH-Zugang.

---

## 📚 Dokumentation (Das Handbuch)

Das Herzstück der Wissensvermittlung in diesem Repo ist unsere strukturierte Bibliothek. 

👉 **[ZUM HANDBUCH INDEX](./bibliothek/Handbuch_Index.md)**

### Kapitel-Direktzugriff:
1. [🏗️ **Architektur & Hardware**](./bibliothek/01_Architektur.md) - Specs, GPU-Power & Spindown.
2. [🛠️ **Betrieb & Workflow**](./bibliothek/02_Betrieb.md) - Aliase (`nsw`, `ntest`), MOTD & Wartung.
3. [🛡️ **Services & Sicherheit**](./bibliothek/03_Services_Sicherheit.md) - Port-Registry (10k/20k) & Killswitch.
4. [💡 **Backlog & Ideen**](./bibliothek/04_Backlog_Ideen.md) - Was die Zukunft bringt.

---

## ⚡ Quick Start (für Moritz)

Wenn du am System arbeitest, nutze die integrierten Aliase:

```bash
ncfg    # Wechselt nach /etc/nixos
ntest   # Testet die Config (temporär bis Reboot)
nsw     # Schaltet die Config scharf (persistent)
nclean  # Räumt die Boot-Partition auf ( Garbage Collect)
```

---

## 🗄️ Archiv
Alte Logs, Entwürfe und historische Dokumente findest du im [**Archiv-Ordner (/old)**](./old/).

---
*Erstellt mit ❤️ und Unterstützung von Gemini & Claude.*
