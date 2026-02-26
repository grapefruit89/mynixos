# 🏗️ PROMPT TEIL 1 von 3: Strukturelle Bereinigung
## Broken Imports · Duplikat-Konsolidierung · nftables-Migration

---

## KONTEXT FÜR DIE AUSFÜHRENDE KI

Du arbeitest an einem NixOS-Homelab-Repository (Fujitsu Q958, NixOS 25.11).
Das Repository liegt unter `/etc/nixos` und ist auf GitHub gespiegelt.

**Bevor du irgendetwas änderst:**
1. Lies `/mnt/skills/public/docx/SKILL.md` — nein, das ist kein Dokument-Task
2. Konsultiere Context7 für aktuelle NixOS-Dokumentation:
   - Library ID: `/websites/nixos_manual_nixos_unstable`
   - Library ID: `/nixos/nixpkgs`
3. Lies die folgenden Dateien vollständig bevor du sie änderst:
   - `10-infrastructure/traefik.nix`
   - `10-infrastructure/traefik-core.nix`
   - `00-core/firewall.nix`
   - `00-core/server-rules.nix`
   - `90-policy/security-assertions.nix`
   - `00-core/system.nix`
   - `configuration.nix`

**Source-Sink-Traceability:** Jede Änderung die du machst MUSS folgendes Kommentarmuster verwenden:
```nix
# source-id: CFG.<gruppe>.<key>   ← wo der Wert herkommt
# sink:   <was damit passiert>    ← was damit gemacht wird
```

---

## AUFGABE 1: `traefik.nix` — Broken Import reparieren

### Problem
```
Datei: 10-infrastructure/traefik.nix
```
```nix
imports = [
  ./traefik-core.nix
  ./traefik-routes-public.nix   # ← EXISTIERT NICHT im Repository
  ./traefik-routes-internal.nix
];
```
`traefik-routes-public.nix` existiert nicht. Die Datei `traefik.nix` wird zwar aktuell
nicht direkt in `configuration.nix` importiert (die Teile werden einzeln eingebunden),
aber die Datei ist eine tickende Zeitbombe: sobald jemand `./10-infrastructure/traefik.nix`
einbindet, bricht der Build sofort mit einem kryptischen Fehler.

### Zusätzliche Analyse die du durchführen musst

Bevor du die Lösung implementierst, prüfe:
```bash
# Im Repository-Root ausführen:
grep -rn "traefik-routes-public" /etc/nixos/
grep -rn "traefik.nix" /etc/nixos/configuration.nix
grep -rn "traefik.nix" /etc/nixos/
```
Dokumentiere die Ergebnisse als Kommentar in der geänderten Datei.

### Lösung A (empfohlen): `traefik.nix` zu einem sauberen Aggregator machen

```nix
# 10-infrastructure/traefik.nix
# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: Traefik Aggregator-Import
#   source-ids: none (nur Import-Sammler)
#   note: traefik-routes-public.nix existiert noch nicht.
#         Platzhalter-Import auskommentiert bis Implementierung erfolgt.
#         Tracking: TODO-TRAEFIK-PUBLIC-001

{ ... }:
{
  imports = [
    ./traefik-core.nix
    # ./traefik-routes-public.nix  # TODO-TRAEFIK-PUBLIC-001: noch nicht implementiert
    ./traefik-routes-internal.nix
  ];
}
```

### Lösung B (alternativ): `traefik.nix` löschen und Direktimporte beibehalten

In `configuration.nix` sind die Traefik-Teile bereits einzeln importiert:
```nix
./10-infrastructure/traefik-core.nix
./10-infrastructure/traefik-routes-internal.nix
```
In diesem Fall: `traefik.nix` mit einem klaren Stub ersetzen der erklärt warum sie
existiert aber leer ist, ODER die Datei löschen und `configuration.nix` so lassen wie sie ist.

**Entscheide dich für eine Lösung und dokumentiere sie in `docs/DECISION_LOG.md`:**
```markdown
### YYYY-MM-DD: traefik.nix Aggregator-Status
- Kontext: traefik-routes-public.nix fehlte, Import war broken
- Entscheidung: [Lösung A / Lösung B]
- Konsequenzen: ...
```

### TODO-Eintrag anlegen

Lege in `docs/OPEN_ITEMS_NOW.md` folgenden Eintrag an:
```markdown
## TODO-TRAEFIK-PUBLIC-001
- Priorität: Mittel
- Beschreibung: traefik-routes-public.nix implementieren
- Inhalt: Öffentliche Traefik-Routen (Services die extern erreichbar sein sollen)
- Pattern: Analog zu traefik-routes-internal.nix aufbauen
- Vorbedingung: Domain + Cloudflare-Setup abgeschlossen
```

---

## AUFGABE 2: Duplikat `server-rules.nix` vs `security-assertions.nix` — Bereinigung

### Problem
```
Datei 1: 00-core/server-rules.nix       (AKTIV — in configuration.nix importiert)
Datei 2: 90-policy/security-assertions.nix  (INAKTIV — auskommentiert)
```

Beide Dateien enthalten **nahezu identische Assertion-Listen**. Das ist ein Wartungsalbtraum:
- Eine Änderung muss doppelt gepflegt werden
- Es ist unklar welche die "wahre" Version ist
- `security-assertions.nix` hat zusätzlich einen Bug (fehlende `user`-Variable in der `let`-Bindung)

### Analyse die du durchführen musst

```bash
# Direkte Gegenüberstellung der Assertion-Inhalte:
diff <(grep "must\|assertion\|message" /etc/nixos/00-core/server-rules.nix) \
     <(grep "must\|assertion\|message" /etc/nixos/90-policy/security-assertions.nix)
```

### Lösung: `server-rules.nix` zum Platzhalterstub degradieren

**WICHTIG: Assertions bleiben KOMPLETT AUSKOMMENTIERT** — der Nutzer ist im Bastelmodus
und will keine blockierenden Assertions. Ziel ist nur strukturelle Bereinigung.

**Schritt 1:** `90-policy/security-assertions.nix` bereinigen und als zukünftige Canonical-Datei vorbereiten:

```nix
# 90-policy/security-assertions.nix
# meta:
#   owner: policy
#   status: draft — ASSERTIONS DEAKTIVIERT (Bastelmodus)
#   scope: shared
#   summary: Zentrale Sicherheits-Assertions (einzige Quelle der Wahrheit)
#   specIds: alle SEC-* IDs aus 90-policy/spec-registry.md
#   note: Aktivieren wenn Bastelphase abgeschlossen.
#         server-rules.nix ist deprecated und wird nach Aktivierung dieser Datei gelöscht.
#         Bug-Fix: user-Variable war in alter Version nicht korrekt definiert.

{ config, lib, ... }:
let
  must = assertion: message: { inherit assertion message; };

  # Alle Abhängigkeiten MÜSSEN vor ihrer Verwendung definiert sein
  # source-id: CFG.identity.user
  user = config.my.identity.user;

  # source: 00-core/ports.nix
  sshPort = config.my.ports.ssh;
  websecurePort = config.my.ports.traefikHttps;

  # source: 00-core/secrets.nix
  sharedSecretEnv = config.my.secrets.files.sharedEnv;

  # Abgeleitete Werte
  fwRules = config.networking.firewall.extraInputRules;
  traefikEnv = config.systemd.services.traefik.serviceConfig.EnvironmentFile or [ ];
  sabBinds = config.systemd.services.sabnzbd.bindsTo or [ ];
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];
  sshdRestart = config.systemd.services.sshd.serviceConfig.Restart or null;
  sshdWantedBy = config.systemd.services.sshd.wantedBy or [ ];
in
{
  # [BASTELMODUS] Alle Assertions auskommentiert.
  # Einkommentieren sobald Grundkonfiguration stabil ist.
  # Dann server-rules.nix löschen.
  assertions = [
    # Secret contract invariants
    # (must (config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName == "CLOUDFLARE_DNS_API_TOKEN") "[SEC-SECRET-CF-001] cloudflare token variable name must be CLOUDFLARE_DNS_API_TOKEN")
    # (must (config.my.secrets.vars.wgPrivadoPrivateKeyVarName == "WG_PRIVADO_PRIVATE_KEY") "security: WireGuard private key variable name must be WG_PRIVADO_PRIVATE_KEY")

    # SSH hardening invariants
    # (must config.services.openssh.enable "[SEC-SSH-SVC-001] services.openssh.enable must remain true")
    # ... (alle weiteren Assertions auskommentiert lassen)
  ];
}
```

**Schritt 2:** `00-core/server-rules.nix` zum Stub-Hinweis degradieren:

```nix
# 00-core/server-rules.nix
# meta:
#   owner: core
#   status: deprecated
#   scope: shared
#   summary: DEPRECATED — wird durch 90-policy/security-assertions.nix ersetzt
#   note: Diese Datei bleibt als leerer Stub bis security-assertions.nix aktiviert wird.
#         Dann diese Datei löschen und Import aus configuration.nix entfernen.
#         Tracking: TODO-ASSERTIONS-CONSOLIDATION-001

{ ... }:
{
  # Inhalt nach 90-policy/security-assertions.nix verschoben.
  # Dort sind alle Assertions korrekt strukturiert und bugfrei.
}
```

**Schritt 3:** `configuration.nix` anpassen:
```nix
# configuration.nix — Security Policy Sektion:
# VORHER:
./00-core/server-rules.nix   # ← aktiv aber deprecated

# NACHHER:
./00-core/server-rules.nix   # bleibt kurzzeitig als leerer Stub
# ./90-policy/security-assertions.nix  # Aktivieren wenn Bastelmodus beendet
```

---

## AUFGABE 3: `configuration.nix` — Duplikate mit `system.nix` bereinigen

### Problem
```
Datei: configuration.nix
```
Folgende Einstellungen sind **doppelt definiert** — einmal in `configuration.nix` und einmal in `00-core/system.nix`:

```nix
# configuration.nix (DUPLIKAT — soll weg):
boot.loader.systemd-boot.enable      = true;   # ← auch in system.nix
boot.loader.efi.canTouchEfiVariables = true;   # ← auch in system.nix
networking.networkmanager.enable = true;        # ← auch in system.nix
environment.systemPackages = with pkgs; [       # ← auch in system.nix (andere Pakete!)
  git htop wget curl tree unzip file
  nix-output-monitor
];
```

### Analyse die du durchführen musst

```bash
# Alle Duplikate zwischen configuration.nix und system.nix finden:
grep -n "boot\.\|networking\.networkmanager\|systemPackages" \
  /etc/nixos/configuration.nix \
  /etc/nixos/00-core/system.nix
```

**Besonderes Augenmerk:** `environment.systemPackages` wird in BEIDEN Dateien gesetzt.
NixOS merged Listen — das bedeutet die Pakete werden addiert, nicht überschrieben.
Das ist kein Bug aber es ist verwirrend weil man nicht weiß welche Datei "führt".

### Lösung: `configuration.nix` auf reine Import-Datei reduzieren

```nix
# configuration.nix — NACH der Bereinigung
{ ... }:
{
  imports = [
    ./hosts/q958/hardware-configuration.nix

    # 00 — Core (Reihenfolge ist wichtig: configs.nix muss zuerst)
    ./00-core/configs.nix
    ./00-core/principles.nix
    ./00-core/logging.nix
    ./00-core/locale.nix
    ./00-core/ports.nix
    ./00-core/host.nix
    ./00-core/secrets.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/motd.nix
    ./00-core/system.nix        # ← system.nix ist die einzige Quelle für Boot/Pakete
    ./00-core/aliases.nix
    ./00-core/fail2ban.nix
    ./00-core/server-rules.nix  # deprecated stub, bis assertions aktiviert werden
    ./automation.nix

    # 10 — Infrastructure
    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik-core.nix
    # ./10-infrastructure/traefik-routes-public.nix  # TODO-TRAEFIK-PUBLIC-001
    ./10-infrastructure/traefik-routes-internal.nix
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/wireguard-vpn.nix
    # ./10-infrastructure/adguardhome.nix    # TODO: erst nach IP-Zentralisierung
    # ./10-infrastructure/pocket-id.nix      # TODO: erst nach Domain-Setup

    # 20 — Media Stack
    ./20-services/media/default.nix
    ./20-services/media/media-stack.nix

    # 20 — Apps
    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/paperless.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix

    # 90 — Policy (im Bastelmodus auskommentiert)
    # ./90-policy/security-assertions.nix  # TODO-ASSERTIONS-CONSOLIDATION-001
  ];

  # KEINE Konfiguration hier — alles in den Modulen!
  # Ausnahme: stateVersion gehört zur Hardware/Host-Spezifik
  system.stateVersion = "25.11";

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];
}
```

**Aus `system.nix` sicherstellen dass folgende Pakete ALLE dort vorhanden sind:**
```nix
# 00-core/system.nix — vollständige Paketliste (merged aus beiden Dateien):
environment.systemPackages = with pkgs; [
  nodejs_22
  alejandra
  git
  htop
  wget
  curl
  tree
  unzip
  file
  nix-output-monitor
  # Alles was bisher nur in configuration.nix stand, hierher verschieben
];
```

---

## AUFGABE 4: nftables-Migration — iptables Legacy-Code entfernen

### Problem
```
Datei: 00-core/firewall.nix
```

**Inkonsistenz-Analyse:**
```
options.my.firewall.backend = lib.mkOption {
  default = "iptables";   ← Standard ist LEGACY
};
```

Gleichzeitig enthält `extraInputRules` nftables-Syntax:
```nix
networking.firewall.extraInputRules = lib.mkForce ''
  ip saddr { ${rfc1918}, ${tailnet} } tcp dport ${toString sshPort} accept
'';
```

`extraInputRules` ist **nftables-only** in NixOS. Mit `backend = "iptables"` wird dieser
Block möglicherweise nicht korrekt verarbeitet.

Zusätzlich: die `extraCommands`/`extraStopCommands`-Blöcke enthalten eine massiven
iptables-Kommando-Duplikation die bei Migration sowieso wegfällt.

### Context7 Referenz
```
Konsultiere: /nixos/nixpkgs
Query: "nftables enable networking firewall extraInputRules"
```

NixOS dokumentiert seit 23.05: `networking.nftables.enable = true` aktiviert das nftables-Backend.
Mit nftables sind `extraInputRules` die primäre Methode — die iptables-Spiegelkommandos sind obsolet.

### Lösung: `firewall.nix` auf nftables-only umstellen

```nix
# 00-core/firewall.nix
# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Firewall — nftables-Backend (iptables legacy entfernt)
#   specIds: [SEC-NET-SSH-001, SEC-NET-SSH-002, SEC-NET-EDGE-001]

{ lib, config, ... }:
let
  sshPort = config.my.ports.ssh;
  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;
  # source-id: CFG.network.tailnetCidrs
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  # KEIN backend-Option mehr — nftables ist der Standard und einzige Backend
  # iptables ist deprecated und wird in zukünftigen NixOS-Versionen entfernt

  config = {
    # [SEC-NET-EDGE-001] nftables als modernes, nicht-deprecated Backend
    networking.nftables.enable = true;
    networking.firewall.enable = true;

    # [SEC-NET-EDGE-001] Global inbound: nur HTTPS
    networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];
    # mDNS für .local (Avahi)
    networking.firewall.allowedUDPPorts = lib.mkForce [ 5353 ];

    # [SEC-NET-SSH-002] SSH explizit über Tailscale Interface
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

    # [SEC-NET-SSH-001]/[SEC-NET-SSH-002] SSH und DNS nur aus Heimnetzen + Tailscale-CGNAT
    # Hinweis: extraInputRules ist nftables-only — korrekt mit networking.nftables.enable = true
    networking.firewall.extraInputRules = lib.mkForce ''
      # [SEC-NET-SSH-002] SSH nur aus privaten Ranges + Tailnet
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport ${toString sshPort} accept

      # DNS nur intern
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
      ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

      # mDNS nur LAN
      ip saddr { ${rfc1918} } udp dport 5353 accept
    '';

    # ENTFERNT: extraCommands / extraStopCommands (iptables legacy — nicht mehr nötig)
    # ENTFERNT: options.my.firewall.backend (kein Toggle mehr — nftables ist fix)
  };
}
```

### Verifikation nach dem Deployment

```bash
# Prüfen ob nftables aktiv ist:
sudo nft list ruleset | grep -A5 "chain input"

# SSH-Zugang testen BEVOR nixos-rebuild switch:
sudo nixos-rebuild test
# In neuem Terminal parallel testen:
ssh -p 53844 moritz@nixhome.local
```

### Risiko-Hinweis ⚠️

**Teste mit `nixos-rebuild test` (temporär, kein switch) bevor du persistierst!**
Bei einem Fehler in den nftables-Regeln kannst du durch Reboot auf die alte Konfiguration zurückfallen.
Mit `nixos-rebuild switch` ist die Änderung permanent bis zum nächsten Rollback.

---

## AUFGABE 5: Repo-Struktur — Bewertung und Empfehlung

### Aktuelle Struktur Bewertung

```
00-core/    — ✅ Sehr gut, bewährtes Muster
10-infra/   — ✅ Gut
20-services/ — ✅ Gut
90-policy/  — ✅ Richtig aufgehoben (policy gehört ans Ende)
```

**Zur Frage: 10.000er IPs für 10-Infrastruktur, 20.000er für 20-Services?**

Das ist **kein unnötiger Schnickschnack** — es ist eine konsequente Umsetzung des
"nichts dem Zufall überlassen"-Prinzips. Empfehlung:

```nix
# 00-core/ports.nix — Portbereiche dokumentieren
config.my.ports = {
  # 00-Core Infrastruktur (1000-9999) — niemals von Services belegt
  ssh = 53844;              # Außerhalb aller Bereiche — bewusst

  # 10-Infrastructure (10000-19999)
  traefikHttps  = 443;      # Ausnahme: Standard-HTTPS-Port
  adguard       = 10001;    # war 3000 → umbenennen
  netdata       = 10002;    # war 19999 → umbenennen  
  uptimeKuma    = 10003;    # war 3001 → umbenennen
  homepage      = 10004;    # war 8082 → umbenennen
  ddnsUpdater   = 10005;    # war 8001 → umbenennen

  # 20-Services Apps (20000-29999)
  vaultwarden   = 20001;    # war 2002
  miniflux      = 20002;    # war 2016
  n8n           = 20003;    # war 2017
  paperless     = 20004;    # war 28981
  scrutiny      = 20005;    # war 2020
  readeck       = 20006;    # war 2007
  monica        = 20007;    # war 2031

  # 20-Services Media (21000-21999)
  jellyfin      = 21001;    # war 8096
  audiobookshelf = 21002;   # war 8000
  sonarr        = 21003;    # war 8989
  radarr        = 21004;    # war 7878
  readarr       = 21005;    # war 8787
  prowlarr      = 21006;    # war 9696
  sabnzbd       = 21007;    # war 8080
  jellyseerr    = 21008;    # war 5055
};
```

**WICHTIG:** Port-Änderungen erfordern Service-Neustarts UND ggf. ARR-API-Neuverdrahtung.
Führe Port-Umbenennung **in einem dedizierten Commit** durch, nicht vermischt mit anderen Änderungen.

Port-Migrationsreihenfolge:
1. `ports.nix` ändern
2. `nixos-rebuild test`
3. Jeden Service manuell testen
4. ARR-Wire neu ausführen: `sudo systemctl start arr-wire.service`
5. `nixos-rebuild switch`

---

## CHECKLISTE FÜR DIE AUSFÜHRENDE KI

Vor dem Commit prüfen:

```bash
# 1. Keine nicht-existierenden Dateien in Imports:
grep -rn "import\|./[a-z]" /etc/nixos/configuration.nix | \
  while read line; do
    file=$(echo $line | grep -o '\./[^"]*\.nix');
    [ -f "/etc/nixos/$file" ] || echo "FEHLT: $file"
  done

# 2. Keine doppelten Boot-Settings:
grep -rn "boot\.loader\|networkmanager" /etc/nixos/00-core/ /etc/nixos/configuration.nix

# 3. nftables aktiv, kein iptables-Backend mehr:
grep -rn "iptables\|extraCommands\|extraStopCommands\|my\.firewall\.backend" /etc/nixos/00-core/firewall.nix

# 4. server-rules.nix ist leer/stub:
wc -l /etc/nixos/00-core/server-rules.nix

# 5. Dry-run vor allem anderen:
cd /etc/nixos && sudo nixos-rebuild dry-run 2>&1 | tail -20
```

---

*Dieses Prompt-Dokument ist Teil 1 von 3. Weiter mit TEIL 2 (AdGuard-Zentralisierung + IDs-Report-Automatisierung) und TEIL 3 (Service-Hardening).*
