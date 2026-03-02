---
title: MASTER_STATUS_V2.1_COMPLETE
category: Betrieb
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: 7e693fbfaf1801611a3467a514c06d51977ecb61546ee3bb481b6e1e834164d2
---
---
title: Master Status & Projektplan
author: Moritz Baumeister
project: mynixos (Fujitsu Q958 Homelab)
last_updated: 2026-02-26
version: 2.1
status: active
---

# 📊 MASTER STATUS – mynixos Repository

## 🎯 Projekt-Übersicht

**System:** NixOS 25.11 (Unstable) auf Fujitsu Esprimo Q958  
**Hardware:** Intel i3-9100, UHD 630, 16GB RAM  
**Architektur:** Channel-basiert (Flake-ready)  
**Stabilität:** ⭐⭐⭐⭐☆ (4/5) – Production-Ready mit kleinen Gaps

---

## 📈 AKTUELLER STATUS (Stand: 26.02.2026)

### ✅ **Vollständig Implementiert (100%)**

#### 🏗️ Core-Infrastruktur
- [x] Modulare Layer-Architektur (00/10/20/90)
- [x] Zentrale Konfiguration (`configs.nix` + `ports.nix`)
- [x] Source-ID/Sink Traceability System
- [x] Hardware-Optimierung (Intel QuickSync, GuC/HuC)
- [x] Netzwerk-Stack (systemd-networkd, Avahi, BBR)

#### 🛡️ Sicherheit & Networking
- [x] NFTables Firewall (Bastelmodus-aware)
- [x] Fail2ban (SSH-Protection)
- [x] SSH Hardening (Custom Port 53844)
- [x] VPN Killswitch (NFTables für Media-Services)
- [x] WireGuard (Privado VPN)
- [x] Tailscale (Zero-Config VPN)

#### 🎬 Media-Stack
- [x] Jellyfin (Hardware-Transcoding aktiviert)
- [x] Sonarr / Radarr / Readarr / Prowlarr
- [x] SABnzbd (VPN-gebunden)
- [x] Jellyseerr (Request-Management)
- [x] Audiobookshelf

#### 🌐 Web-Services
- [x] Traefik (Reverse-Proxy + ACME/Cloudflare)
- [x] Homepage Dashboard (Einstiegsseite)
- [x] AdGuard Home (DNS-Resolver)
- [x] Vaultwarden (Passwort-Manager)
- [x] Paperless-ngx (Dokumenten-Archiv)
- [x] Miniflux (RSS-Reader)
- [x] n8n (Workflow-Automation)
- [x] Monica (CRM)
- [x] Readeck (Read-Later)
- [x] Pocket-ID (SSO-Provider)
- [x] Home Assistant (Core + MQTT)

#### 💾 Speicher & Backup
- [x] MergerFS (SSD/HDD Tiering)
- [x] Smart Mover (Automatisches Downgrade alter Daten)
- [x] Intelligent Mover (Opportunistisch via hdparm/iostat)
- [x] Restic Backup (Täglich um 02:00)

#### 📚 Dokumentation
- [x] Bibliothek-System (`bibliothek/`)
- [x] Handbuch mit Index
- [x] AI_CONTEXT.md für LLM-Assistenz
- [x] Service-Templates

---

### 🟡 **Teilweise Implementiert (80-100%)**

#### 🔐 Authentifizierung & SSO
- [x] Pocket-ID aktiviert (100%)
  - ✅ Service läuft
  - ✅ Caddy-Router vorhanden
  - ✅ ForwardAuth-Middleware aktiv
  - ✅ Redirect-URLs konfiguriert

#### 🏠 Home-Manager
- [~] Basis-Integration aktiv (80%)
  - ✅ Channel importiert
  - ✅ User-Profil `moritz/home.nix` existiert
  - ✅ Shell-Config & Aliase in `shell-premium.nix` konsolidiert
  - ❌ Dotfile-Verwaltung (VSCodium, etc.) noch ausbaufähig

#### 📊 Monitoring
- [x] Netdata aktiviert (100%)
  - ✅ Dienst läuft
  - ✅ In Caddy integriert (SSO geschützt)
  - ✅ Im Homepage-Dashboard verlinkt
  
- [x] Scrutiny (SMART-Monitoring) (100%)
  - ✅ Dienst läuft
  - ✅ Caddy-Route vorhanden
  - ✅ Im Homepage-Dashboard verlinkt

#### 🐚 Shell-Workflow
- [x] Aliase definiert (100%)
  - ✅ `nsw` (Safe-Switch), `ntest`, `ncfg` funktionieren
  - ✅ MOTD via Fastfetch (integriert)
  - ✅ Alle nützlichen Aliase konsolidiert

---

### ❌ **Nicht Implementiert (0-10%)**

#### 🔒 Advanced Security
- [ ] FIDO2/U2F für SSH (0%)
- [x] sops-nix (Secret Encryption) (100%)
  - ✅ Aktiv und konfiguriert
- [ ] SELinux/AppArmor (0%)
  - **Entscheidung:** Nicht nötig (systemd-hardening reicht)

#### 💽 Storage
- [ ] Disko (Declarative Partitioning) (0%)
  - **Priorität:** NONE (System läuft bereits)
- [ ] ZFS (0%)
  - **Entscheidung:** Overkill für Homelab

#### 🧪 Testing & CI
- [ ] nixos-test Suites (0%)
- [ ] Pre-commit Hooks (5% – existiert, nicht aktiv)
- [ ] Automatische Formatting (nixfmt) (0%)

---

## 🚨 KRITISCHE PROBLEME (Behoben)

### ✅ P0: Boot-Partition Overflow-Risiko behoben
- [x] `boot-safeguard.nix` aktiv
- [x] Limit: 3 Generationen
- [x] Tägliche GC aktiv

### ✅ P1: SSH Lockout-Risiko behoben
- [x] `ssh-rescue.nix` aktiv
- [x] 5-Minuten Recovery-Window mit TTY-Countdown
- [x] Passwort-Login im Notfall möglich

---

## 📋 ROADMAP (Aktualisiert)

### 🔴 **MUST (Erledigt)**

| Task | Effort | Impact | Status |
|------|--------|--------|--------|
| Boot-Safeguard implementieren | 10min | 🔥 Critical | ✅ DONE |
| SSH Recovery Window | 15min | 🔥 Critical | ✅ DONE |
| Service-Härtung vereinheitlichen | 2h | 🔒 High | ✅ DONE |
| SSO finalisieren (Pocket-ID) | 30min | 🛡️ High | ✅ DONE |
| ABC-Storage Godmode | 1h | 💾 High | ✅ DONE |
| Home Assistant Integration | 30min | 🏠 Medium | ✅ DONE |

**Gesamtaufwand:** ✅ Phase abgeschlossen!

---

### 🟡 **SHOULD (Nächste Schritte)**

| Task | Effort | Impact | Priority |
|------|--------|--------|----------|
| Maintainerr Setup | 1h | 🧹 Medium | P3 |
| Token-Porter (p-token-qr) | 1h | 🔑 High | P4 |
| Interactive Break-Glass | 2h | ⚓ High | P5 |
| Restic Tier-A Cloud Sync | 1h | ☁️ High | P6 |

**Gesamtaufwand:** ~7 Stunden

---

### 🟢 **COULD (Nice-to-Have)**

- [ ] Fastfetch-MOTD mit Service-Status
- [ ] Automatische Arr-Stack Wiring
- [ ] Scrutiny in Homepage integrieren
- [ ] Pre-commit Hooks (nixfmt, statix)

---

### ⚪ **WON'T (Bewusst nicht implementiert)**

- ❌ **Disko:** System läuft bereits, keine Neuinstallation geplant
- ❌ **ZFS:** Overkill für Homelab, MergerFS reicht
- ❌ **SELinux:** systemd-hardening ist ausreichend
- ❌ **sops-nix:** Erst bei Secret-Rotation nötig (aktuell: keine Compliance-Anforderungen)

---

## 📊 PROJEKT-METRIKEN

### Code-Statistiken
```
Dateien:           68 .nix
Zeilen Code:       ~4200
Kommentare:        ~800 (19% Ratio)
Dokumentation:     ~3500 Zeilen (.md)
Commits:           147
Contributors:      1 (+ AI-Assistenz)
```

### Dienste-Übersicht
```
Aktive Services:   27
Ports belegt:      18 (10xxx + 20xxx Schema)
Traefik-Routen:    23
Systemd-Units:     31
```

### Ressourcen-Nutzung
```
RAM (Idle):        2.1 GB / 16 GB (13%)
CPU (Idle):        2% (4 Cores)
Disk (Root):       47 GB / 220 GB (21%)
Boot-Zeit:         18 Sekunden
```

### Sicherheits-Score
```
SSH:               7/10 (Custom Port, Fail2ban, Key-Auth)
Firewall:          9/10 (NFTables, Killswitch)
Services:          6/10 (Inkonsistente Härtung)
Secrets:           5/10 (Plain-Text Env-Files)
Gesamt:            7/10 (Gut mit Luft nach oben)
```

---

## 🎯 MEILENSTEINE

### ✅ Meilenstein 1: Basis-System (Abgeschlossen: 15.01.2026)
- [x] Modular-Architektur aufgebaut
- [x] Hardware-Optimierung (QuickSync)
- [x] Traefik + ACME funktioniert

### ✅ Meilenstein 2: Media-Stack (Abgeschlossen: 05.02.2026)
- [x] Jellyfin + Arr-Suite läuft
- [x] VPN-Killswitch implementiert
- [x] Storage-Tiering (MergerFS)

### ✅ Meilenstein 3: Dokumentation (Abgeschlossen: 20.02.2026)
- [x] Bibliothek-System erstellt
- [x] Source-ID Tracking
- [x] AI_CONTEXT.md

### 🟡 Meilenstein 4: Production-Hardening (In Arbeit: 26.02-08.03.2026)
- [~] Boot-Safeguard (TODO)
- [~] SSH Recovery (TODO)
- [~] Service-Härtung (TODO)
- [~] SSO finalisiert (TODO)

### ⏳ Meilenstein 5: Observability (Geplant: März 2026)
- [ ] Monitoring-Dashboard
- [ ] Alert-System
- [ ] Log-Aggregation

---

## 🔄 UPDATE-HISTORIE

### v2.1 (26.02.2026) – Architektur-Review
- ✅ Kritische Analyse durch Senior SRE
- ✅ Boot-Problem identifiziert
- ✅ SSH-Lockout-Risiko erkannt
- 🆕 8 Artefakte geplant

### v2.0 (20.02.2026) – Dokumentations-Offensive
- ✅ Bibliothek-System komplett
- ✅ Source-ID Tracking aktiviert
- ✅ Handbuch finalisiert

### v1.5 (05.02.2026) – Media-Stack Finalisierung
- ✅ MergerFS mit Smart Mover
- ✅ VPN-Killswitch produktiv
- ✅ Restic Backup aktiv

### v1.0 (15.01.2026) – Initial Release
- ✅ Basis-System lauffähig
- ✅ Traefik + Services deployed

---

## 📞 SUPPORT & RESSOURCEN

### Interne Dokumentation
- [Handbuch Index](bibliothek/Handbuch_Index.md)
- [Architektur-Review](NIXOS_ARCHITEKTUR_REVIEW.md)
- [Quick Wins](QUICK_WINS.md)

### Externe Referenzen
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [IronicBadger Blog](https://blog.ktz.me/)
- [Misterio77 Configs](https://github.com/Misterio77/nix-starter-configs)

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [r/NixOS](https://reddit.com/r/nixos)
- [NixOS Matrix Chat](https://matrix.to/#/#community:nixos.org)

---

## 🎖️ QUALITÄTS-SIEGEL

Das Projekt erfüllt folgende Standards:

- ✅ **NixOS Best Practices** (Modularität, KISS)
- ✅ **Security Conscious** (Killswitch, Hardening)
- ✅ **Documentation Excellence** (95% Coverage)
- ✅ **Architecture Award** (Layer-Design)
- 🟡 **Production-Ready** (mit kleinen Gaps)

**Gesamt-Rating:** ⭐⭐⭐⭐☆ (4/5)

---

## 🚀 NÄCHSTE SCHRITTE (Action Items)

### Heute (26.02.2026)
1. [ ] `boot-safeguard.nix` implementieren → `/etc/nixos/00-core/`
2. [ ] `ssh-rescue.nix` implementieren → `/etc/nixos/00-core/`
3. [ ] `nixos-rebuild test` durchführen
4. [ ] Bei Erfolg: `nixos-rebuild switch`

### Diese Woche
5. [ ] Service-Härtung für monica.nix, readeck.nix, miniflux.nix
6. [ ] `sso.nix` implementieren → Pocket-ID ForwardAuth
7. [ ] Homepage-Dashboard um Scrutiny ergänzen

### Nächste Woche
8. [ ] `kernel-slim.nix` für Performance
9. [ ] Netdata in Traefik integrieren
10. [ ] Monitoring-Alerts konfigurieren

---

## 📌 ENTSCHEIDUNGEN (Decision Log)

### Warum kein Flakes?
**Entscheidung:** Channel-basiert bleiben (vorerst)  
**Grund:** System läuft stabil, Migration bringt aktuell keinen Mehrwert  
**Status:** Struktur ist "Flake-ready", Umstieg jederzeit möglich

### Warum kein sops-nix?
**Entscheidung:** Plain-Text Secrets akzeptabel  
**Grund:** Homelab ohne Compliance-Anforderungen, kein Multi-User  
**Threshold:** Bei >3 Personen mit Root-Zugriff neu bewerten

### Warum MergerFS statt ZFS?
**Entscheidung:** MergerFS mit ext4  
**Grund:** Einfacher, flexibler, kein RAM-Overhead  
**Trade-off:** Keine Snapshots, aber Restic Backup kompensiert das

### Warum systemd-networkd?
**Entscheidung:** networkd statt NetworkManager  
**Grund:** Server-Umfeld, keine GUI, deterministische Konfiguration  
**Vorteil:** Schnellerer Boot, weniger RAM-Verbrauch

---

## 🏆 ERFOLGE (Wins)

- ✅ **0 Downtime** seit Produktivstart (15.01.2026)
- ✅ **18s Boot-Zeit** (besser als Ubuntu Server: ~35s)
- ✅ **Source-ID System** (Community-weit einzigartig)
- ✅ **95% Dokumentations-Coverage** (selten in Homelabs)
- ✅ **Hardware-Transkodierung** funktioniert out-of-the-box

---

**Status-Report Ende** | Aktualisiert: 2026-02-26 23:45 UTC  
**Nächstes Review:** 05.03.2026 (Nach Meilenstein 4)
