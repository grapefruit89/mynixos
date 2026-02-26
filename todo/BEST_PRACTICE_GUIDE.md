# Best Practice Guide – NixOS Q958 Optimierungen
## Konkrete Code-Snippets und Schritt-für-Schritt-Anweisungen

**Ziel:** Behebung der kritischen und wichtigen Lücken aus dem Architektur-Review  
**Stand:** 26. Februar 2026

---

## 🎯 Überblick: Was wird optimiert?

| Kategorie | Maßnahmen | Priorität | Dateien |
|-----------|-----------|-----------|---------|
| **Hardware** | Microcode, GuC/HuC, Boot | 🔴 HOCH | `system.nix`, `hardware-configuration.nix` |
| **Sicherheit** | SSH, Kernel-Sysctl | 🔴 HOCH | `ssh.nix`, `system.nix` |
| **Performance** | Nix-Store, Build-Settings | 🟡 MITTEL | `system.nix` |
| **Workflow** | Shell-Aliase, MOTD | 🟡 MITTEL | `00-core/shell.nix` (neu) |
| **Cleanup** | Deprecated-Files, Docs | 🟢 NIEDRIG | Verschiedene |

---

## 📦 Teil 1: Hardware-Optimierungen

### 1.1 Intel Microcode aktivieren

**Problem:** Security-Updates für CPU (Spectre/Meltdown) fehlen.

**Lösung:**

Öffne `hosts/q958/hardware-configuration.nix` (oder `00-core/system.nix`):

```nix
# In hardware-configuration.nix NACH der `{` Zeile einfügen:
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ /* ... */ ];
  
  # NEU: Intel Microcode-Updates aktivieren
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Rest der Datei bleibt unverändert
  boot.initrd.availableKernelModules = [ /* ... */ ];
  # ...
}
```

**Warum `lib.mkDefault`?**  
Erlaubt Override in anderen Modulen, aber setzt sinnvollen Default.

**Test:**
```bash
sudo nixos-rebuild test
dmesg | grep microcode
# Erwartete Ausgabe: "microcode updated early to revision 0x..."
```

---

### 1.2 Intel GuC/HuC Firmware (UHD 630)

**Problem:** Hardware-Beschleunigung für Video-Encoding nicht optimal.

**Lösung:**

Öffne `00-core/system.nix`:

```nix
{ config, lib, pkgs, ... }:
{
  # Bestehende Boot-Konfiguration erweitern:
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 3;  # NEU: Boot-Timeout von 5s auf 3s reduzieren
    };
    
    # NEU: Kernel-Parameter für bessere Intel-GPU-Performance
    kernelParams = [
      "i915.enable_guc=2"  # GuC/HuC Firmware-Loading aktivieren
      # Optional für Debug:
      # "i915.enable_fbc=1"    # Framebuffer Compression
      # "i915.fastboot=1"      # Schnellerer Boot
    ];
    
    # NEU: Kernel-Module explizit laden
    kernelModules = [ "i915" ];
  };
  
  # Rest der Datei bleibt unverändert
}
```

**Was macht `enable_guc=2`?**
- Wert 1: Nur GuC (Command Submission)
- Wert 2: GuC + HuC (Hardware-Codec-Beschleunigung)
- Wert 3: Experimental (nicht empfohlen)

**Test:**
```bash
sudo nixos-rebuild test
dmesg | grep -i guc
# Erwartete Ausgabe: "i915 0000:00:02.0: [drm] GuC firmware i915/kbl_guc_70.1.1.bin version 70.1"
# Erwartete Ausgabe: "i915 0000:00:02.0: [drm] HuC firmware i915/kbl_huc_4.0.0.bin version 4.0"
```

**Verifizierung für Jellyfin:**
```bash
sudo systemctl restart jellyfin
# In Jellyfin Dashboard → Playback → Transcoding prüfen:
vainfo --display drm --device /dev/dri/renderD128
# Sollte zeigen: VAProfileH264Main, VAProfileHEVCMain, etc.
```

---

### 1.3 Boot-Optimierung

**Problem:** Standard-Timeout verschwendet Zeit.

**Lösung (bereits in 1.2 integriert):**
```nix
boot.loader.timeout = 3;  # Statt 5 Sekunden
```

**Alternative (noch schneller, nur für Profis):**
```nix
boot.loader.timeout = 1;  # Nur 1 Sekunde
# VORSICHT: Wenig Zeit für Rollback-Auswahl im Boot-Menü!
```

---

## 🔒 Teil 2: Sicherheits-Härtung

### 2.1 SSH-Härtung

**Problem:** Fehlende Timeouts und Login-Limits.

**Lösung:**

Öffne `00-core/ssh.nix`:

```nix
{ lib, config, pkgs, ... }:
let
  sshPort = config.my.ports.ssh;
  user = config.my.configs.identity.user;
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];
  allowPasswordFallback = !hasAuthorizedKeys;
  # ...
in
{
  services.openssh = {
    enable = true;
    openFirewall = false;
    ports = lib.mkForce [ sshPort ];

    settings = {
      PermitRootLogin = lib.mkForce "no";
      PermitTTY = lib.mkForce true;
      PasswordAuthentication = lib.mkForce allowPasswordFallback;
      KbdInteractiveAuthentication = lib.mkForce allowPasswordFallback;
      AllowUsers = [ "${user}" ];
      
      # NEU: Härtungs-Parameter
      LoginGraceTime = 20;              # Timeout bei Login-Prompt: 20 Sekunden
      MaxAuthTries = 3;                 # Nur 3 Passwort-Versuche
      ClientAliveInterval = 300;        # Keep-Alive alle 5 Minuten
      ClientAliveCountMax = 2;          # Nach 2 fehlenden Responses: Disconnect
      
      # Optional (zusätzliche Paranoia):
      MaxSessions = 10;                 # Max. parallele Sessions pro Netzwerk-Verbindung
      PermitEmptyPasswords = false;     # Sollte schon default sein, aber explizit
      # X11Forwarding = false;          # Wenn du X11 nicht brauchst
    };

    # Bestehende extraConfig bleibt unverändert
    extraConfig = ''
      Match Address 127.0.0.1,::1,${matchCidrs}
        PermitTTY yes
        AllowUsers ${user}
    '';
  };
  
  # Rest der Datei bleibt unverändert (fail2ban-Warning etc.)
}
```

**Test:**
```bash
sudo nixos-rebuild test

# Test 1: Timeout
ssh -p 53844 moritz@localhost
# Warte 25 Sekunden ohne Passwort → sollte Verbindung abbrechen

# Test 2: Max Auth Tries
ssh -p 53844 moritz@localhost
# Gib 4x falsches Passwort ein → sollte beim 4. Mal disconnecten
```

---

### 2.2 Kernel-Härtung (sysctl)

**Problem:** Kernel ist nicht gegen Netzwerk-Angriffe gehärtet.

**Lösung:**

Öffne `00-core/system.nix`, füge nach der `nix = { ... }` Sektion ein:

```nix
{ config, lib, pkgs, ... }:
{
  # Bestehende Konfiguration bleibt unverändert
  boot = { /* ... */ };
  nix = { /* ... */ };
  
  # NEU: Kernel-Sysctl-Härtung
  boot.kernel.sysctl = {
    # == Netzwerk-Härtung ==
    # Reverse Path Filtering (Schutz vor IP-Spoofing)
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    
    # Ignoriere ICMP-Broadcasts (Smurf-Angriffe verhindern)
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    
    # Keine Source-Routing-Pakete akzeptieren
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    
    # ICMP-Redirects ignorieren (Man-in-the-Middle-Schutz)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    
    # Secure ICMP-Redirects
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    
    # Logging von verdächtigen Paketen
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    
    # == Kernel-Pointer-Protection ==
    # Verhindert Auslesen von Kernel-Adressen (Security durch Obscurity, aber gut)
    "kernel.kptr_restrict" = 2;  # 2 = auch root darf nicht lesen
    
    # Kernel-Logs nur für root lesbar
    "kernel.dmesg_restrict" = 1;
    
    # == SYN-Flood-Schutz ==
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_syn_retries" = 2;
    "net.ipv4.tcp_synack_retries" = 2;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    
    # == Optional: IPv6-Härtung (wenn IPv6 verwendet wird) ==
    "net.ipv6.conf.all.use_tempaddr" = 2;         # Privacy Extensions
    "net.ipv6.conf.default.use_tempaddr" = 2;
    "net.ipv6.conf.all.accept_ra" = 0;            # Keine Router Advertisements
    "net.ipv6.conf.default.accept_ra" = 0;
  };
  
  # Rest der Datei bleibt unverändert
  environment.systemPackages = [ /* ... */ ];
}
```

**Test:**
```bash
sudo nixos-rebuild test

# Verifiziere Settings:
sysctl net.ipv4.conf.all.rp_filter
# Erwartete Ausgabe: net.ipv4.conf.all.rp_filter = 1

sysctl kernel.kptr_restrict
# Erwartete Ausgabe: kernel.kptr_restrict = 2
```

---

## ⚡ Teil 3: Performance-Optimierungen

### 3.1 Nix-Store-Settings

**Problem:** `keep-outputs` und `keep-derivations` verhindern aggressives GC.

**Lösung:**

Öffne `00-core/system.nix`:

```nix
nix = {
  settings = {
    auto-optimise-store = true;  # BLEIBT
    
    # NEU: Optimal für i3-9100 mit 16GB RAM
    max-jobs = 4;     # GEÄNDERT von 3 → 4 (alle Cores nutzen)
    cores = 4;        # BLEIBT
    
    # Binary Caches BLEIBEN
    substituters = [ /* ... */ ];
    trusted-public-keys = [ /* ... */ ];
    
    # Flake-Features BLEIBEN (auch ohne aktive Flakes)
    experimental-features = [ "nix-command" "flakes" ];
    
    # NUR wenn du aktiv an Nix-Paketen entwickelst:
    # keep-outputs = true;
    # keep-derivations = true;
    # ANDERNFALLS: LÖSCHEN oder auskommentieren
  };
  
  # GC-Settings BLEIBEN unverändert
  gc = { /* ... */ };
  optimise = { /* ... */ };
};
```

**Entscheidungshilfe:**
- **Paket-Entwicklung?** → `keep-outputs = true` lassen
- **Nur System-Admin?** → Löschen, spart NVMe-Platz

**Test:**
```bash
# VOR der Änderung:
nix-store --gc --print-dead | wc -l

sudo nixos-rebuild switch

# NACH der Änderung:
nix-store --gc --print-dead | wc -l
# Sollte deutlich mehr Einträge zeigen (mehr GC-fähiger Müll)
```

---

### 3.2 Build-Performance messen

**Baseline erstellen:**
```bash
# Vor Optimierungen:
time sudo nixos-rebuild dry-run
# Notiere die Zeit, z.B. "real 0m45.234s"

# Nach allen Optimierungen:
time sudo nixos-rebuild dry-run
# Sollte ca. 10-20% schneller sein
```

---

## 🧹 Teil 4: Cleanup

### 4.1 Port-Kollision beheben

**Problem:** `adguard` und `pocketId` beide auf Port 3000.

**Lösung:**

Öffne `00-core/ports.nix`:

```nix
config.my.ports = {
  ssh = 53844;
  traefikHttps = 443;
  
  # GEÄNDERT: pocketId aus 3000-Bereich verschieben
  adguard = 3000;         # BLEIBT (nicht aktiv derzeit)
  pocketId = 10010;       # GEÄNDERT von 3000 → 10010 (10k Infrastructure-Bereich)
  
  netdata = 19999;        # BLEIBT (oder 10001 im 10k-Schema)
  uptimeKuma = 3001;      # BLEIBT (oder 10002 im 10k-Schema)
  homepage = 8082;        # BLEIBT (oder 10003 im 10k-Schema)
  ddnsUpdater = 8001;     # BLEIBT (oder 10004 im 10k-Schema)
  
  # Rest bleibt unverändert
  jellyfin = 8096;
  # ...
};
```

**Optional: 10k-Port-Schema konsequent durchziehen:**
```nix
# Infrastructure (10000-19999):
adguard = 10000;
pocketId = 10001;
netdata = 10002;
uptimeKuma = 10003;
homepage = 10004;
ddnsUpdater = 10005;

# Apps (20000-20999):
vaultwarden = 20000;
miniflux = 20001;
n8n = 20002;
# ...

# Media (21000-21999):
jellyfin = 21000;
audiobookshelf = 21001;
# ...
```

**WICHTIG nach Port-Änderungen:**
```bash
# 1. Test
sudo nixos-rebuild test

# 2. Services neu starten
sudo systemctl restart jellyfin sonarr radarr

# 3. ARR-Wire neu ausführen (wenn Port-Änderungen in Media-Stack)
sudo systemctl start arr-wire.service
```

---

### 4.2 Deprecated-Files löschen

**Dateien zum Löschen:**
```bash
cd /etc/nixos

# Sicherstellen dass sie wirklich leer/deprecated sind:
wc -l 00-core/server-rules.nix 00-core/de-config.nix

# Löschen:
git rm 00-core/server-rules.nix
git rm 00-core/de-config.nix
git rm 00-core/dummy.nix  # Template-Datei, nicht in Prod

# Commit:
git commit -m "cleanup: deprecated stub-files entfernt"
```

**Imports aus `configuration.nix` entfernen:**
```nix
# In configuration.nix LÖSCHEN:
# ./00-core/server-rules.nix  ← Diese Zeile komplett weg
```

---

### 4.3 Traefik Rate-Limiting verschärfen

**Problem:** `average = 100` ist zu lasch für Homelab.

**Lösung:**

Öffne `10-infrastructure/traefik-core.nix`:

```nix
http.middlewares = {
  # ... andere Middlewares ...
  
  rate-limit.rateLimit = {
    average = 50;   # GEÄNDERT von 100 → 50
    burst = 100;    # GEÄNDERT von 200 → 100
  };
  
  # Rest bleibt unverändert
};
```

**Test:**
```bash
sudo systemctl reload traefik

# Stress-Test (optional):
ab -n 200 -c 10 https://jellyfin.m7c5.de/
# Ab Request 101 sollten 429-Errors kommen
```

---

## 🔧 Teil 5: Workflow-Modul installieren

### 5.1 Shell-Modul hinzufügen

**Datei:** Das `shell.nix` aus der Code-Ausgabe speichern als:
```
/etc/nixos/00-core/shell.nix
```

**Import hinzufügen:**

Öffne `configuration.nix`:

```nix
imports = [
  # ...
  ./00-core/system.nix
  ./00-core/aliases.nix  # ← Bestehend (kann bleiben oder entfernen)
  ./00-core/shell.nix    # ← NEU
  # ...
];
```

**Optional:** Altes `aliases.nix` löschen, da `shell.nix` umfassender ist.

**Test:**
```bash
sudo nixos-rebuild test

# SSH neu connecten:
ssh -p 53844 moritz@q958

# Du solltest jetzt das MOTD sehen + alle Aliase funktionieren:
nsw --help
ntest --help
```

---

## 📚 Teil 6: Dokumentation konsolidieren

### 6.1 Master-README erstellen

**Datei:** `/etc/nixos/README.md`

**Minimal-Template:**
```markdown
# NixOS Homelab – Fujitsu Q958

## Quick Start

**System testen:**
```bash
sudo nixos-rebuild test
```

**System persistieren:**
```bash
sudo nixos-rebuild switch
```

**Cleanup:**
```bash
nclean  # Alias für GC
```

## Dokumentation

- **Architektur:** `docs/architecture.md`
- **Operations:** `docs/operations.md`
- **Troubleshooting:** `02_FEHLERBEHEBUNG.md`

## Wichtige Aliase

Siehe SSH-MOTD oder `00-core/shell.nix`.

## Support

- Repository: https://github.com/grapefruit89/mynixos
- Issues: https://github.com/grapefruit89/mynixos/issues
```

---

### 6.2 Docs-Struktur

**Alte Struktur:**
```
.
├── 00_BETRIEBSANLEITUNG.md
├── 01_ARCHITEKTUR.md
├── 02_FEHLERBEHEBUNG.md
├── docs_backup/
│   ├── OPERATIONS_RUNBOOK.md
│   └── ...
```

**Neue Struktur (Ziel):**
```
.
├── README.md                     # Neues Master-Dokument
├── docs/
│   ├── architecture.md           # Aus 01_ARCHITEKTUR.md
│   ├── operations.md             # Aus docs_backup/OPERATIONS_RUNBOOK.md
│   ├── troubleshooting.md        # Aus 02_FEHLERBEHEBUNG.md
│   └── archive/                  # Alte Versionen
│       ├── 00_BETRIEBSANLEITUNG.md
│       └── ...
```

**Migration:**
```bash
cd /etc/nixos

# Neue Struktur erstellen:
mkdir -p docs/archive

# Dateien verschieben:
mv 01_ARCHITEKTUR.md docs/architecture.md
mv 02_FEHLERBEHEBUNG.md docs/troubleshooting.md
mv docs_backup/OPERATIONS_RUNBOOK.md docs/operations.md

# Alte Docs archivieren:
mv 00_BETRIEBSANLEITUNG.md docs/archive/
mv 03_HISTORIE_LOG.md docs/archive/
mv 04_LLM_CONTEXT.md docs/archive/

# Git:
git add -A
git commit -m "docs: Struktur konsolidiert, Master-README erstellt"
```

---

## 🚦 Gesamt-Checkliste

### Phase 1: Kritisch (Diese Woche)
- [ ] Microcode aktiviert (`hardware.cpu.intel.updateMicrocode`)
- [ ] Port-Kollision behoben (`pocketId = 10010`)
- [ ] SSH-Härtung komplett (LoginGraceTime, MaxAuthTries)
- [ ] Shell-Modul installiert (`00-core/shell.nix`)
- [ ] Deprecated-Files gelöscht (server-rules, de-config, dummy)

### Phase 2: Wichtig (Nächste Woche)
- [ ] GuC/HuC aktiviert (`i915.enable_guc=2`)
- [ ] Kernel-Sysctl-Härtung (`boot.kernel.sysctl`)
- [ ] Nix-Store optimiert (`max-jobs = 4`, keep-* entfernt)
- [ ] Boot-Timeout reduziert (`timeout = 3`)
- [ ] Traefik Rate-Limiting verschärft

### Phase 3: Nice-to-Have (Später)
- [ ] Dokumentation konsolidiert (Master-README)
- [ ] 10k-Port-Schema durchgezogen (optional)
- [ ] Pre-Commit-Hooks (nixfmt, statix)
- [ ] devShells für Entwicklung

---

## 🧪 Integrations-Test nach allen Änderungen

**Test-Script:**
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Pre-Deployment Checks ==="

# 1. Syntax-Check
nix-instantiate --parse /etc/nixos/configuration.nix >/dev/null && echo "✓ Syntax OK"

# 2. Dry-Run
sudo nixos-rebuild dry-run 2>&1 | tail -5

echo ""
echo "=== Test-Deployment ==="
sudo nixos-rebuild test

echo ""
echo "=== Service-Checks ==="
systemctl is-active sshd && echo "✓ SSH"
systemctl is-active traefik && echo "✓ Traefik"
systemctl is-active jellyfin && echo "✓ Jellyfin"

echo ""
echo "=== Hardware-Checks ==="
dmesg | grep -i microcode | tail -1
dmesg | grep -i guc | tail -1

echo ""
echo "=== Kernel-Checks ==="
sysctl net.ipv4.conf.all.rp_filter
sysctl kernel.kptr_restrict

echo ""
echo "Alles OK? Dann:"
echo "  sudo nixos-rebuild switch"
```

---

## 📊 Erwartete Verbesserungen

| Metrik | Vorher | Nachher | Verbesserung |
|--------|--------|---------|--------------|
| Boot-Zeit | ~20s | ~15s | -25% |
| Nix-Build | 45s | 35s | -22% |
| Jellyfin-Transcoding | Funktional | Optimal | +Stabilität |
| SSH-Security | Gut | Sehr gut | Härter |
| NVMe-Nutzung | 70% | 60% | -10% (durch GC) |

---

## 🔗 Weiterführende Ressourcen

- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **Intel Graphics:** https://nixos.wiki/wiki/Intel_Graphics
- **Kernel Hardening:** https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project
- **Systemd Security:** https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Sandboxing

---

**Viel Erfolg! Bei Fragen:**
- GitHub Issues: https://github.com/grapefruit89/mynixos/issues
- NixOS Discourse: https://discourse.nixos.org/
