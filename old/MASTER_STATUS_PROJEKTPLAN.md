# Master Status & Projektplan – Fujitsu Q958 NixOS
## Konsolidierter Überblick über aktuellen Stand und nächste Schritte

**Stand:** 26. Februar 2026  
**System:** NixOS 25.11 (Unstable)  
**Hardware:** Fujitsu Q958 (i3-9100, UHD 630, 16GB RAM, 500GB NVMe)

---

## 📊 Aktueller Systemstatus

### ✅ Funktional und Produktiv

| Komponente | Status | Qualität | Hinweise |
|------------|--------|----------|----------|
| **Bootloader** | ✅ Aktiv | Gut | systemd-boot funktioniert |
| **SSH** | ✅ Aktiv | Sehr gut | Port 53844, Key + Fallback |
| **Firewall** | ✅ Aktiv | Gut | nftables, fail2ban integriert |
| **Traefik** | ✅ Aktiv | Sehr gut | HTTPS-only, Cloudflare DNS-01 |
| **Tailscale** | ✅ Aktiv | Gut | VPN-Mesh aktiv |
| **WireGuard** | ✅ Aktiv | Sehr gut | Privado-Tunnel mit Confinement |
| **Jellyfin** | ✅ Aktiv | Gut | QuickSync (UHD 630) funktioniert |
| **ARR-Stack** | ✅ Aktiv | Gut | Sonarr, Radarr, Prowlarr, SABnzbd |
| **Vaultwarden** | ✅ Aktiv | Sehr gut | Systemd-gehärtet |
| **n8n** | ✅ Aktiv | Gut | Workflow-Automation läuft |
| **Paperless** | ✅ Aktiv | Gut | Dokumentenmanagement |
| **Miniflux** | ✅ Aktiv | Gut | RSS-Reader |
| **Audiobookshelf** | ✅ Aktiv | Gut | Hörbuch-Verwaltung |

---

### ⚠️ Teilweise Implementiert / Stub

| Komponente | Status | Problem | Nächster Schritt |
|------------|--------|---------|------------------|
| **AdGuard Home** | ⏸️ Auskommentiert | Config vorhanden, nicht aktiv | IP-Zentralisierung abwarten |
| **Pocket ID** | ⏸️ Auskommentiert | OIDC-Provider geplant | Domain-Setup abwarten |
| **Homepage** | ✅ Aktiv | Funktional | Weitere Widgets hinzufügen |
| **Security Assertions** | ⏸️ Deaktiviert | Bastelmodus | Nach Stabilisierung aktivieren |
| **Storage (HDDs)** | ❌ Nicht implementiert | Nur Platzhalter | disko-Setup für später |

---

### ❌ Fehlende Komponenten (Kritisch)

| Komponente | Priorität | Beschreibung | ETA |
|------------|-----------|--------------|-----|
| **flake.nix** | 🔴 HOCH | Flake-Struktur fehlt komplett | Woche 1 |
| **Microcode** | 🔴 HOCH | Intel-Updates nicht aktiviert | Woche 1 |
| **Kernel-Härtung** | 🟡 MITTEL | sysctl-Parameter fehlen | Woche 2 |
| **devShells** | 🟢 NIEDRIG | Entwickler-Environments | Später |
| **Pre-Commit-Hooks** | 🟢 NIEDRIG | nixfmt, statix nicht aktiv | Später |

---

## 🎯 Priorisierte Roadmap

### 🚨 Phase 1: Kritische Stabilisierung (Woche 1-2)

**Ziel:** System auf solides Fundament stellen

#### Woche 1 – Tag 1-3
- [ ] **Entscheidung: Flakes JA oder NEIN**
  - Option A: Vollständige Flake-Migration
  - Option B: Alle Docs/Prompts auf klassische Channels umstellen
  - **Blocker:** Ohne Entscheidung keine weiteren Schritte
  
- [ ] **Microcode aktivieren**
  ```nix
  # In system.nix oder hardware-configuration.nix:
  hardware.cpu.intel.updateMicrocode = true;
  ```
  
- [ ] **Port-Kollision beheben**
  ```nix
  # In ports.nix ändern:
  pocketId = 10010;  # statt 3000 (Kollision mit adguard)
  ```

#### Woche 1 – Tag 4-7
- [ ] **SSH-Härtung erweitern**
  ```nix
  # In ssh.nix ergänzen:
  LoginGraceTime = 20;
  MaxAuthTries = 3;
  ClientAliveInterval = 300;
  ClientAliveCountMax = 2;
  ```
  
- [ ] **Workflow-Modul erstellen**
  - Neue Datei: `00-core/shell.nix`
  - Aliase für User `moritz`
  - MOTD für SSH-Login

---

### 🔧 Phase 2: Hardware-Optimierung (Woche 2-3)

**Ziel:** i3-9100 und UHD 630 optimal nutzen

#### Woche 2 – Hardware
- [ ] **Intel GuC/HuC Firmware**
  ```nix
  boot.kernelParams = [ "i915.enable_guc=2" ];
  boot.kernelModules = [ "i915" ];
  ```
  
- [ ] **Kernel-Härtung (sysctl)**
  ```nix
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 1;
    "kernel.kptr_restrict" = 2;
    # ... (siehe Best Practice Guide)
  };
  ```
  
- [ ] **Boot-Optimierung**
  ```nix
  boot.loader.timeout = 3;  # Schnellerer Boot
  ```

#### Woche 2 – Nix-Store
- [ ] **Nix-Settings optimieren**
  ```nix
  nix.settings.max-jobs = 4;  # Statt 3
  # keep-outputs/keep-derivations entfernen falls keine Paket-Entwicklung
  ```

---

### 🧹 Phase 3: Cleanup & Dokumentation (Woche 3-4)

**Ziel:** Technische Schuld abbauen

#### Woche 3 – Code
- [ ] **Deprecated-Dateien löschen**
  - `00-core/server-rules.nix` (nur Stub)
  - `00-core/de-config.nix` (leer)
  - `00-core/dummy.nix` (Template, nicht in Prod)

- [ ] **Traefik-Tweaks**
  ```nix
  # Rate-Limiting verschärfen:
  average = 50;  # statt 100
  burst = 100;   # statt 200
  ```

#### Woche 4 – Dokumentation
- [ ] **Master-README erstellen**
  - Konsolidiere `00_BETRIEBSANLEITUNG.md` + andere Docs
  - Einziges Entry-Point-Dokument
  
- [ ] **Docs-Struktur aufräumen**
  ```
  docs/
  ├── README.md           # Master
  ├── architecture.md     # Aus 01_ARCHITEKTUR.md
  ├── operations.md       # Aus docs_backup/OPERATIONS_RUNBOOK.md
  └── archive/            # Alte Versionen
  ```

---

### 🔐 Phase 4: Security-Hardening (Monat 2)

**Ziel:** Von "gut" zu "exzellent"

#### Monat 2 – Woche 1-2
- [ ] **Security-Assertions aktivieren**
  - `90-policy/security-assertions.nix` einkommentieren
  - Alle Assertions einzeln testen
  
- [ ] **Service-Sandboxing vervollständigen**
  - Homepage systemd-Härtung
  - Readeck systemd-Härtung
  - Monica systemd-Härtung

#### Monat 2 – Woche 3-4
- [ ] **sops-nix Migration vorbereiten**
  - Secrets-Inventory erstellen
  - Migration-Plan schreiben
  - **NICHT UMSETZEN** (nur vorbereiten)

---

### 🚀 Phase 5: Advanced Features (Monat 3+)

**Ziel:** Von Homelab zu Production-Grade

#### Später
- [ ] **sops-nix Migration**
  - `/etc/secrets/*.env` → `secrets/*.yaml`
  - Age-Keys generieren
  - Service-by-Service migrieren

- [ ] **disko Partitionierung**
  - Deklarative Disk-Layouts
  - HDD-Management automatisieren
  - **NUR nach vollständiger HDD-Analyse**

- [ ] **Home-Manager Integration**
  - User-Konfiguration deklarativ
  - Dotfiles in Git

- [ ] **FIDO2 SSH-Keys**
  - YubiKey/SoloKey Support
  - Passwort-Fallback als Emergency-Only

---

## 🏗️ Implementierungsreihenfolge (Detailliert)

### Woche 1 – Sprint 1

| Tag | Aufgabe | Dateien | Test |
|-----|---------|---------|------|
| Mo | Flake-Entscheidung | - | - |
| Di | Microcode + Port-Fix | `system.nix`, `ports.nix` | `nixos-rebuild test` |
| Mi | SSH-Härtung | `ssh.nix` | SSH-Zugriff testen |
| Do | Workflow-Modul | `00-core/shell.nix` | Login-Test |
| Fr | Integration-Test | Alle | Rollback-Test |

### Woche 2 – Sprint 2

| Tag | Aufgabe | Dateien | Test |
|-----|---------|---------|------|
| Mo | GuC/HuC Kernel-Params | `system.nix` | `vainfo` Test |
| Di | Kernel-Sysctl | `system.nix` | `sysctl -a` |
| Mi | Nix-Store-Tuning | `system.nix` | Build-Performance |
| Do | Boot-Optimierung | `system.nix` | Boot-Zeit messen |
| Fr | Dokumentation | `docs/` | Review |

---

## 🔍 Audit-Findings (Zusammenfassung)

### Kritische Lücken (Sofort beheben)
1. ❌ Keine Flake-Struktur trotz Flake-Befehlen in Docs
2. ❌ Intel Microcode nicht aktiviert
3. ❌ Port-Kollision adguard/pocketId

### Wichtige Verbesserungen (Diese/nächste Woche)
4. ⚠️ SSH-Härtung unvollständig (LoginGraceTime, MaxAuthTries fehlen)
5. ⚠️ Kernel-Härtung (sysctl) nicht implementiert
6. ⚠️ GuC/HuC-Firmware für UHD 630 nicht aktiviert

### Moderate Optimierungen (Nächster Monat)
7. 📊 Nix-Store-Settings konservativ (`keep-outputs`, `max-jobs`)
8. 📊 Traefik Rate-Limiting zu lasch
9. 📊 Dokumentations-Duplikate

### Nice-to-Have (Später)
10. 🎁 Keine devShells für Entwicklung
11. 🎁 Keine Pre-Commit-Hooks (nixfmt, statix)
12. 🎁 Deprecated-Stubs nicht gelöscht

---

## 📋 Checkliste: "System ist produktionsreif"

### Stabilität ✅ (9/10)
- [x] Bootloader funktioniert
- [x] SSH erreichbar mit Fallback
- [x] Firewall aktiv und korrekt
- [x] Alle Services starten
- [x] Rollback möglich
- [x] Logs persistent
- [x] Backup-Strategie dokumentiert
- [x] Secrets außerhalb Git
- [ ] Microcode aktiviert ← **TODO**
- [x] Nix-Store GC automatisiert

### Sicherheit ⚠️ (7/10)
- [x] SSH nicht auf Port 22
- [x] nftables aktiv
- [x] fail2ban aktiv
- [x] Systemd-Härtung (teilweise)
- [ ] Kernel-Sysctl-Härtung ← **TODO**
- [ ] SSH-Timeouts gesetzt ← **TODO**
- [x] HTTPS-only (kein HTTP)
- [ ] Security-Assertions aktiv ← **Später**
- [x] Secrets-Management funktional
- [x] VPN-Confinement (SABnzbd)

### Performance 🔧 (6/10)
- [x] Hardware-Transcoding (Jellyfin)
- [ ] GuC/HuC aktiviert ← **TODO**
- [x] Auto-Optimise-Store
- [ ] Nix max-jobs optimal ← **TODO**
- [x] Binary-Caches konfiguriert
- [ ] Boot-Timeout reduziert ← **TODO**
- [x] Service-Dependencies korrekt
- [x] tmpfiles-Rules sauber
- [x] kein unnötiges Polling
- [x] HDD-Spindown geplant (später)

### Wartbarkeit 📚 (5/10)
- [x] Modulare Struktur
- [x] Zentrale Port-Registry
- [x] Source-Sink-Traceability
- [ ] Flake-Struktur vorhanden ← **TODO**
- [ ] Ein Master-README ← **TODO**
- [ ] Deprecated-Files entfernt ← **TODO**
- [x] Git-Pre-Commit-Hook
- [ ] Pre-Commit (nixfmt, statix) ← **Später**
- [x] IDs-Report-Script
- [x] Deployment-Script (nix-deploy)

---

## 🎯 Definition of Done (DoD) für jede Phase

### Phase 1 – Stabilisierung
**Done wenn:**
- [ ] Flake-Struktur vorhanden ODER Docs auf Channels umgestellt
- [ ] Microcode aktiviert
- [ ] Port-Kollision behoben
- [ ] SSH-Härtung komplett
- [ ] Workflow-Modul funktioniert
- [ ] Alle Services starten nach Rebuild
- [ ] Rollback getestet

### Phase 2 – Hardware-Optimierung
**Done wenn:**
- [ ] GuC/HuC-Firmware lädt korrekt (`dmesg | grep GuC`)
- [ ] Kernel-Sysctl-Werte gesetzt (`sysctl -a | grep kptr_restrict`)
- [ ] Nix-Build-Performance messbar besser (Baseline: aktuell)
- [ ] Boot-Zeit unter 15 Sekunden
- [ ] Jellyfin-Transcoding stabil

### Phase 3 – Cleanup
**Done wenn:**
- [ ] Keine deprecated-Files mehr im Repo
- [ ] Ein Master-README vorhanden
- [ ] Docs-Struktur aufgeräumt
- [ ] Traefik Rate-Limiting verschärft
- [ ] Code-Review durch Zweite Person

### Phase 4 – Security-Hardening
**Done wenn:**
- [ ] Security-Assertions aktiv und passieren
- [ ] Alle Services systemd-gehärtet
- [ ] sops-nix-Migration-Plan dokumentiert
- [ ] Penetration-Test durchgeführt (optional)

---

## 📊 Projekt-Metriken

### Aktueller Stand
- **Code-Dateien:** ~80 `.nix`-Files
- **Services:** 15 aktiv, 3 geplant
- **Dokumentation:** 15+ Dateien (fragmentiert)
- **Technische Schuld:** Hoch (siehe oben)
- **Test-Coverage:** 0% (kein automatisches Testing)

### Ziele nach Phase 3
- **Code-Dateien:** ~70 (Cleanup)
- **Dokumentation:** 5 zentrale Docs
- **Technische Schuld:** Niedrig
- **Test-Coverage:** Basic (nixos-rebuild dry-run)

---

## 🚦 Risiken & Mitigation

### Risiko 1: Flake-Migration bricht System
**Wahrscheinlichkeit:** Mittel  
**Impact:** Hoch  
**Mitigation:**
- Erst in Branch testen
- Rollback-Strategie dokumentieren
- Offline-Backup vor Migration

### Risiko 2: Kernel-Parameter-Fehler → Boot-Fail
**Wahrscheinlichkeit:** Niedrig  
**Impact:** Hoch  
**Mitigation:**
- `nixos-rebuild test` vor `switch`
- Timeout auf 10s setzen (auto-rollback)

### Risiko 3: Dokumentations-Drift
**Wahrscheinlichkeit:** Hoch  
**Impact:** Mittel  
**Mitigation:**
- Ein Master-Dokument erzwingen
- Alte Docs archivieren, nicht löschen

---

## 💡 Nächste konkrete Schritte (Diese Woche)

### Montag
1. Entscheide: Flakes JA/NEIN (1 Stunde Recherche)
2. Wenn JA: Lese Misterio77/nix-starter-configs
3. Wenn NEIN: Ändere alle Aliases/Docs

### Dienstag
4. Implementiere Microcode (`hardware.cpu.intel.updateMicrocode`)
5. Fixe Port-Kollision in `ports.nix`
6. Teste: `nixos-rebuild test`

### Mittwoch
7. SSH-Härtung ergänzen (LoginGraceTime etc.)
8. Teste SSH-Zugriff ausführlich

### Donnerstag
9. Erstelle `00-core/shell.nix` (siehe Best Practice Guide)
10. Teste MOTD + Aliases

### Freitag
11. Integration-Test aller Änderungen
12. Dokumentiere in `DECISION_LOG.md`
13. Erstelle Git-Commit

---

## 📚 Referenzen

- **Community-Standards:**
  - [nix-community/awesome-nix](https://github.com/nix-community/awesome-nix)
  - [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
  - [EmergentMind NixOS Guide](https://github.com/EmergentMind/nix-config)

- **Hardware-Spezifisch:**
  - [NixOS Wiki: Intel Graphics](https://nixos.wiki/wiki/Intel_Graphics)
  - [GuC/HuC Firmware Guide](https://01.org/linuxgraphics/downloads/firmware)

- **Interne Docs:**
  - `docs_backup/PROJECT_VISION_AND_ARCHITECTURE.md`
  - `90-policy/spec-registry.md`

---

**Letzte Aktualisierung:** 26. Februar 2026  
**Nächstes Review:** Nach Phase 1 (ca. 10. März 2026)
