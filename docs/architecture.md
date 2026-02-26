# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Systemarchitektur, Netzwerk und Firewall-Konzept
#   specIds: [ARCH-001, SEC-NET-001]

# 🏗️ Architektur & Netzwerk

Dieses Dokument erklärt den Aufbau deiner NixOS-Konfiguration und wie die Sicherheit gewährleistet wird.

## 📂 Struktur des Repositories
Die Konfiguration ist modular aufgebaut:

- **`00-core/`**: Das Fundament. Hier liegen:
  - `configs.nix`: Zentrale Werte (IPs, Domain, User). **Single Source of Truth.**
  - `firewall.nix`: Das NFTables-Setup.
  - `ssh.nix`: Abgesicherter Fernzugriff.
  - `locale.nix`: Tastatur (Deutsch!) und Sprache.
- **`10-infrastructure/`**: Plattform-Dienste (Traefik, Tailscale, WireGuard).
- **`20-services/`**: Deine Anwendungen (Audiobookshelf, Vaultwarden, etc.).
- **`90-policy/`**: Sicherheitsregeln (Assertions), die prüfen, ob alles korrekt konfiguriert ist.

## 🛡️ Firewall (NFTables Only)
Wir haben das System komplett auf **NFTables** umgestellt.
- **Legacy-Iptables** wurde entfernt.
- **Strategie:** Alles ist zu, außer was explizit erlaubt ist.
- **Regeln:**
  - SSH (Port 22) ist nur aus dem Heimnetz und über Tailscale erlaubt.
  - HTTPS (Port 443) ist für Traefik offen.
  - DNS ist nur intern erreichbar.

## 🌐 Netzwerk-Konzept
Alle wichtigen Netzwerk-Definitionen findest du in `00-core/configs.nix`:
- **Heimnetz (LAN):** `192.168.0.0/16`, `10.0.0.0/8`, `172.16.0.0/12`.
- **Tailscale:** `100.64.0.0/10`.
- **Domain:** Deine Hauptdomain ist in `my.configs.identity.domain` hinterlegt.

## ⌨️ Lokalisierung
Das System ist auf **Deutsch** eingestellt:
- Tastatur: `de-latin1` (Konsole) und `de` (X11).
- Zeitzone: `Europe/Berlin`.
- Locale: `de_DE.UTF-8`.
