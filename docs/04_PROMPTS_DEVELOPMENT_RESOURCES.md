---
title: NixOS Homelab Development Resources & Prompts
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated
type: Development Logic & Prompts
---

# 🤖 DEVELOPMENT RESOURCES & PROMPTS

Dieses Dokument enthält strukturelle Prompts, architektonische Entscheidungen und Logik-Patterns für die Entwicklung des NixOS-Homelabs.

## 🧠 Entscheidungs-Log (Decision Log)

### Konsolidierung der Reverse-Proxy Architektur
- **Kontext**: Redundanz zwischen Traefik und Caddy.
- **Entscheidung**: Migration zu Caddy aufgrund der einfacheren Syntax und exzellenten NixOS-Integration. Traefik-Konfigurationen werden schrittweise in Caddy Snippets (`sso_auth`, `security_headers`) überführt.

### "Source-ID" Tracking System
- **Kontext**: Verfolgung von geteilten Werten (IPs, Domains, Ports) über Module hinweg.
- **Muster**: Verwendung von `# source-id: CFG.<gruppe>.<key>` Kommentaren in Modulen, um die Herkunft aus `configs.nix` zu dokumentieren. Automatischer ID-Report via `scan-ids.sh`.

---

## 🛠️ Entwicklungs-Prompts (Templates)

### Teil 1: Strukturelle Bereinigung
- **Fokus**: Broken Imports reparieren, Duplikate in `configuration.nix` vs `system.nix` löschen.
- **Ziel**: `configuration.nix` soll eine reine Import-Liste sein.

### Teil 2: Netzwerk & ID-Automatisierung
- **Fokus**: Hardcodierte IPs entfernen, `configs.nix` erweitern.
- **Automatisierung**: `scripts/scan-ids.sh` generiert `ids-report.md` und `.json`.

### Teil 3: Service-Härtung
- **Fokus**: Systemd Sandbox-Profile (PrivateTmp, ProtectSystem, etc.).
- **Besonderheit**: Explizite Handhabung von Hardware-Zugriff (`renderD128`) vs. Isolation.

---

## 💎 Goldnuggets & Logic Patterns

### Option-Exhaustion Pattern
Bei der Implementierung neuer Dienste (z.B. AdGuard, Valkey) sollten **alle** relevanten NixOS-Optionen erschöpft werden, um "UI-Silos" zu vermeiden. Einstellungen sollten deklarativ in Nix statt imperativ in der Web-UI erfolgen.

### Bastelmodus-Logik
```nix
bastelmodus = lib.mkOption {
  default = false; # SICHERER DEFAULT
  description = "Deaktiviert Firewall und Assertions für Debugging.";
};
```
Der Bastelmodus muss explizit aktiviert werden und sollte einen Alarm (Wall-Message) im System auslösen, wenn er aktiv ist.

---

## 📜 Snippets & Ressourcen
- **`shell.nix`**: Optimiertes Shell-Modul mit Aliases (`nsw`, `ntest`, `nclean`) und MOTD.
- **Cloudflare Auto-Discovery**: Script-Muster zur automatischen Domain-Erkennung via API (Nice-to-Have).

---
*Dokument Ende.*
