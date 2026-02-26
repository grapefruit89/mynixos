# NixOS Architektur Review – Fujitsu Q958
## Kritische Analyse der aktuellen Konfiguration

**Stand:** 26. Februar 2026  
**System:** NixOS 25.11 (Unstable), Fujitsu Q958 (i3-9100, UHD 630, 16GB RAM)  
**Repository:** https://github.com/grapefruit89/mynixos

---

## 🎯 Executive Summary

Deine NixOS-Konfiguration zeigt ein **solides Grundgerüst** mit durchdachter Modulstruktur, aber es gibt **erhebliches Optimierungspotenzial** in drei Kernbereichen:

1. **🚨 KRITISCH:** Kein Flake-Setup trotz expliziter Erwartung in deinen Prompts
2. **⚠️ WICHTIG:** Fehlende Hardware-Optimierungen für den i3-9100
3. **📊 MODERAT:** Verbesserungsfähige Nix-Store-Einstellungen und Service-Härtung

**Gesamtbewertung:** 6.5/10 – Funktional, aber nicht optimal

---

## 🔍 Detaillierte Befunde

### 1. Fehlende Flake-Struktur (KRITISCH)

**Problem:**  
In deinem Repository existiert **keine `flake.nix`**. Deine Prompt-Dokumente und Aliases referenzieren aber explizit Flake-Befehle wie:
- `sudo nixos-rebuild switch --flake .#q958`
- `nix flake update`

**Auswirkung:**
- Deine angegebenen Workflows funktionieren nicht
- Keine Reproduzierbarkeit durch `flake.lock`
- Keine Versionspinning von Inputs

**Empfehlung:**  
Entweder:
- **A)** Vollständig auf Flakes migrieren (empfohlen für Stabilität)
- **B)** Alle Dokumentation/Prompts auf klassische Channels umstellen

**Priorität:** 🔴 HOCH

---

### 2. Hardware-Optimierungen fehlen

**Aktuelle Lücken:**

#### 2.1 Intel Microcode
```nix
# FEHLT in system.nix oder hardware-configuration.nix:
hardware.cpu.intel.updateMicrocode = true;
```

**Warum wichtig:**  
Security-Patches für Spectre/Meltdown-Varianten, Stabilitätskorrekturen.

#### 2.2 Intel QuickSync (UHD 630) – Teilweise richtig
**Gut:**
- `intel-media-driver` (iHD) korrekt
- `LIBVA_DRIVER_NAME = "iHD"` gesetzt
- Kernel-Module werden implizit geladen

**Verbesserungspotenzial:**
```nix
# In jellyfin.nix oder system.nix ergänzen:
boot.kernelParams = [
  "i915.enable_guc=2"  # GuC/HuC Firmware für bessere Media-Performance
];

# Explizit sicherstellen:
boot.kernelModules = [ "i915" ];
```

#### 2.3 Systemd Boot-Optimierung
```nix
# Aktuell: Standard-Timeout
# Besser:
boot.loader.timeout = 3;  # Schnellerer Boot
```

**Priorität:** 🟡 MITTEL

---

### 3. Nix-Store-Optimierung suboptimal

**Aktuelle Konfiguration:**
```nix
nix.settings = {
  auto-optimise-store = true;  # ✅ Gut
  max-jobs = 3;                # ⚠️ Konservativ
  cores = 4;                   # ✅ Korrekt
  keep-outputs = true;         # ⚠️ Diskutabel
  keep-derivations = true;     # ⚠️ Diskutabel
};
```

**Probleme:**

1. **`keep-outputs = true` + `keep-derivations = true`:**  
   - Verhindert aggressives GC
   - Auf einem 500GB NVMe-System mit vielen Services kann das kritisch werden
   - Nur sinnvoll bei aktiver Entwicklung an Paketen

2. **`max-jobs = 3`:**  
   - Zu konservativ für einen 4-Core-i3
   - Bei 16GB RAM kannst du `max-jobs = 4` setzen (Memory pro Job ~2GB)

**Empfohlene Anpassung:**
```nix
nix.settings = {
  auto-optimise-store = true;
  max-jobs = 4;      # Voll ausnutzen bei genug RAM
  cores = 4;
  
  # NUR wenn du aktiv Pakete entwickelst:
  # keep-outputs = true;
  # keep-derivations = true;
};
```

**Priorität:** 🟢 NIEDRIG (funktioniert, aber nicht optimal)

---

### 4. Sicherheits-Härtung unvollständig

**Gut gemacht:**
- ✅ Systemd-Härtung für Jellyfin, Traefik, Vaultwarden, n8n
- ✅ nftables statt iptables
- ✅ fail2ban aktiv
- ✅ SSH-Port nicht default

**Lücken:**

#### 4.1 SSH-Härtung
```nix
# FEHLT in ssh.nix:
services.openssh.settings = {
  # Bestehende Settings...
  
  # Zusätzlich empfohlen:
  LoginGraceTime = 20;           # Verbindung nach 20s abbrechen
  MaxAuthTries = 3;              # Nur 3 Login-Versuche
  ClientAliveInterval = 300;     # Idle-Timeout
  ClientAliveCountMax = 2;
  
  # Optional (für Security-Paranoia):
  # HostbasedAuthentication = false;
  # IgnoreRhosts = true;
};
```

#### 4.2 Kernel-Härtung
```nix
# FEHLT in system.nix:
boot.kernel.sysctl = {
  # Networking-Hardening
  "net.ipv4.conf.all.rp_filter" = 1;
  "net.ipv4.conf.default.rp_filter" = 1;
  "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  "net.ipv4.conf.all.accept_source_route" = 0;
  "net.ipv6.conf.all.accept_source_route" = 0;
  
  # Kernel-Pointer-Protection
  "kernel.kptr_restrict" = 2;
  "kernel.dmesg_restrict" = 1;
};
```

**Priorität:** 🟡 MITTEL

---

### 5. Modulstruktur – Fast perfekt

**Positive Punkte:**
- ✅ Klare Trennung: `00-core`, `10-infrastructure`, `20-services`, `90-policy`
- ✅ Zentrale Port-Registry
- ✅ Zentrale Config-Werte (`configs.nix`)
- ✅ Source-Sink-Traceability mit CFG-IDs

**Verbesserungspotenzial:**

1. **Deprecated-Dateien aufräumen:**
   ```bash
   # Diese Dateien löschen:
   00-core/server-rules.nix  # Ist nur noch Stub
   00-core/de-config.nix     # Leer
   00-core/dummy.nix         # Template nicht in Prod
   ```

2. **Flake-Migration-Struktur:**
   ```
   mynixos/
   ├── flake.nix          # ← FEHLT
   ├── flake.lock         # ← FEHLT
   ├── hosts/
   │   └── q958/
   │       └── default.nix
   └── modules/
       ├── 00-core/
       ├── 10-infrastructure/
       └── 20-services/
   ```

**Priorität:** 🟢 NIEDRIG (funktioniert, aber Cleanup wünschenswert)

---

### 6. Service-Spezifische Befunde

#### 6.1 Jellyfin (Intel QuickSync)
**Gut:**
- Hardware-Zugriff korrekt (`/dev/dri`, `video`, `render`)
- Moderne Treiber (`intel-media-driver`)

**Verbesserung:**
```nix
# Optional für bessere Performance:
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver
  intel-compute-runtime
  vpl-gpu-rt  # Intel VPL für neuere Codecs (AV1)
];
```

#### 6.2 Traefik
**Gut:**
- Cloudflare DNS-Challenge
- HTTPS-only (Port 80 disabled)
- Separates Environment-File für Secrets

**Lücke:**
```nix
# FEHLT: Rate-Limiting auf Traefik-Ebene verschärfen
services.traefik.dynamicConfigOptions.http.middlewares.rate-limit = {
  rateLimit = {
    average = 50;   # Aktuell: 100 (zu lasch)
    burst = 100;    # Aktuell: 200
  };
};
```

#### 6.3 SABnzbd (VPN-Confinement)
**Hervorragend:**
- ✅ `RestrictNetworkInterfaces = [ "lo" "privado" ]`
- ✅ `bindsTo` WireGuard-Service
- ✅ DNS-Leak-Mitigation

**Keine Änderung nötig.**

---

### 7. Dokumentations-Chaos

**Problem:**  
Mehrere konkurrierende Dokumentationsquellen:
- `00_BETRIEBSANLEITUNG.md`
- `docs_backup/` mit 10+ Dateien
- `todo/PROMPT_TEIL1_*.md` (3 große Prompt-Dateien)

**Empfehlung:**
1. Ein **Master-Dokument** erstellen: `README.md`
2. Alte Backups nach `docs/archive/` verschieben
3. Prompts nach `docs/prompts/` auslagern

**Priorität:** 🟡 MITTEL (Benutzerfreundlichkeit)

---

## 📋 Antipattern-Analyse

### 🚨 Antipattern 1: Manuelle Secrets-Verwaltung
**Aktuell:**
```bash
/etc/secrets/homelab-runtime-secrets.env
```

**Problem:**
- Nicht in Git
- Kein Audit-Trail
- Rotation manuell

**Besser (später):**
```nix
# Mit sops-nix:
sops.secrets.cloudflare-token = {
  sopsFile = ./secrets/production.yaml;
  owner = "traefik";
};
```

**Status:** 🟡 Akzeptiert für "Getting Things Running"-Phase

---

### ⚠️ Antipattern 2: Global Flake-Features ohne Flake
```nix
# In system.nix:
experimental-features = [ "nix-command" "flakes" ];
```

**Problem:**  
Du aktivierst Flake-Support, nutzt aber keine Flakes.

**Lösung:**  
Entweder Flakes implementieren oder Feature-Flag entfernen.

---

### ⚠️ Antipattern 3: Port-Duplikate
```nix
# ports.nix:
adguard = 3000;
pocketId = 3000;  # ← Kollision!
```

**Auswirkung:**  
Wenn beide Services aktiviert werden → Port-Konflikt.

**Fix:**
```nix
pocketId = 3001;  # oder 10010 im 10k-Schema
```

---

## 🎯 Priorisierte To-Do-Liste

### Woche 1: Kritische Fixes
1. ✅ Entscheiden: Flakes JA/NEIN
2. ✅ Microcode aktivieren
3. ✅ Port-Duplikat beheben
4. ✅ SSH-Härtung ergänzen

### Woche 2: Optimierungen
5. ✅ Kernel-Parameter für i915 GuC
6. ✅ Nix-Store-Settings anpassen
7. ✅ Kernel-Sysctl-Härtung
8. ✅ Boot-Timeout reduzieren

### Woche 3: Cleanup
9. ✅ Deprecated-Dateien löschen
10. ✅ Dokumentation konsolidieren
11. ✅ Traefik Rate-Limiting verschärfen

### Später (Monat 2-3):
12. 🔐 sops-nix Migration
13. 💾 disko Partitionierung
14. 🔒 FIDO2 SSH-Keys

---

## 🔬 Technische Schuld (Technical Debt)

### Hohe Priorität
- [ ] Flake-Struktur vs. Dokumentation inkonsistent
- [ ] Port-Kollision (adguard/pocketId)
- [ ] Microcode-Updates fehlen

### Mittlere Priorität
- [ ] Kernel-Härtung (sysctl) nicht implementiert
- [ ] GuC/HuC-Firmware nicht aktiviert
- [ ] Dokumentations-Duplikate

### Niedrige Priorität
- [ ] `keep-outputs`/`keep-derivations` für Desktop-Workflow nicht ideal
- [ ] Deprecated-Stubs nicht gelöscht
- [ ] Keine devShells für Entwicklung

---

## 🏆 Best Practice Alignment

### Was du richtig machst (Community-Standard):
1. ✅ **Modulare Struktur:** Analog zu Misterio77's Setup
2. ✅ **Zentrale Port-Registry:** Wie nix-community empfiehlt
3. ✅ **Systemd-Härtung:** Über Community-Standard
4. ✅ **nftables:** Modern, kein iptables-Legacy
5. ✅ **Secrets außerhalb Git:** Korrekt (auch ohne sops)

### Was fehlt (vs. Community-Best-Practice):
1. ❌ **Kein Flake:** 90% der modernen NixOS-Setups nutzen Flakes
2. ❌ **Keine devShells:** Standard für reproduzierbare Dev-Environments
3. ❌ **Keine Pre-Commit-Hooks:** `nixfmt`, `statix` fehlen
4. ❌ **Kein Home-Manager:** Für User-Konfiguration (optional)

---

## 📊 Fazit

**Dein Setup ist operativ stabil**, zeigt aber **architektonische Inkonsistenzen** (Flake-Erwartung vs. Realität). Die **Service-Härtung ist vorbildlich**, aber die **Hardware-Optimierung** für den i3-9100 hat Luft nach oben.

**Empfehlung:**  
1. **Sofort:** Flake-Entscheidung treffen + Microcode
2. **Diese Woche:** Kernel-Parameter + SSH-Härtung
3. **Nächste Woche:** Dokumentation aufräumen + Nix-Store-Tuning

**Gesamtwertung:** 6.5/10 → Mit Flakes + Hardware-Fixes: **8.5/10**
