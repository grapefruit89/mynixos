# 🌐 PROMPT TEIL 2 von 3: AdGuard-Zentralisierung · Network-Config · IDs-Report
## Hardcodierte IPs raus · configs.nix erweitern · IDs-Script automatisieren

---

## KONTEXT FÜR DIE AUSFÜHRENDE KI

Du arbeitest an einem NixOS-Homelab-Repository (Fujitsu Q958).
Das Grundprinzip dieses Repos: **alles außerhalb von `00-core/` darf keine hardcodierten Werte enthalten.**
`00-core/configs.nix` ist die einzige Source of Truth für alle geteilten Konfigurationswerte.

**Bevor du irgendetwas änderst:**
1. Konsultiere Context7 für aktuelle NixOS-Dokumentation:
   - Library ID: `/websites/nixos_manual_nixos_unstable`
   - Library ID: `/nixos/nixpkgs`
   - Query für AdGuard: `"adguardhome NixOS options settings"`
   - Query für Network: `"networking NixOS options hostName domain"`
2. Lies vollständig:
   - `00-core/configs.nix`
   - `10-infrastructure/adguardhome.nix`
   - `00-core/ids-report.json`
   - `00-core/ids-report.md`

---

## AUFGABE 1: `configs.nix` erweitern — Server-IPs zentralisieren

### Problem
```
Datei: 10-infrastructure/adguardhome.nix
```
```nix
bind_hosts = [
  "127.0.0.1"
  "192.168.2.73"      # ← hardcodierte LAN-IP — BRICHT bei IP-Wechsel
  "100.113.29.82"     # ← hardcodierte Tailscale-IP — BRICHT bei Tailnet-Reassignment
];
```

Alle Werte **außerhalb von `00-core/`** müssen aus `configs.nix` kommen.
Das ist kein Stil-Problem — es ist ein operatives Risiko.

### Lösung: `configs.nix` um Server-Adressen erweitern

Füge folgende Options-Blöcke in `00-core/configs.nix` ein:

```nix
# 00-core/configs.nix — Erweiterung (in den options.my.configs Block einfügen)

options.my.configs = {
  # ... bestehende identity + network Options bleiben unverändert ...

  server = {
    # source-id: CFG.server.lanIP
    lanIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.73";
      description = "Primäre LAN-IP des Servers. Einzige Stelle wo diese IP definiert wird.";
      example = "192.168.1.100";
    };

    # source-id: CFG.server.tailscaleIP
    tailscaleIP = lib.mkOption {
      type = lib.types.str;
      default = "100.113.29.82";
      description = "Tailscale-IP des Servers. Ändert sich bei Tailnet-Neukonfiguration.";
      example = "100.x.y.z";
    };

    # source-id: CFG.server.bindAddresses
    # Abgeleiteter Wert — nicht separat setzen, wird aus lanIP + tailscaleIP gebaut
    # Genutzt von: adguardhome, services die auf allen Interfaces lauschen sollen
  };
};
```

**Ergänze auch den `config`-Block** in `configs.nix` um einen Konsistenz-Check:
```nix
config = {
  # ... bestehende Einträge ...

  assertions = [
    {
      # source-id: CFG.server.lanIP
      assertion = config.my.configs.server.lanIP != "";
      message = "CFG.server.lanIP muss gesetzt sein (z.B. '192.168.2.73')";
    }
    {
      # source-id: CFG.server.tailscaleIP
      assertion = config.my.configs.server.tailscaleIP != "";
      message = "CFG.server.tailscaleIP muss gesetzt sein (z.B. '100.x.y.z')";
    }
  ];
};
```

### Vollständige neue `adguardhome.nix`

```nix
# 10-infrastructure/adguardhome.nix
# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: AdGuard Home DNS-Resolver (LAN + Tailscale)
#   dependsOn: ["00-core/configs.nix", "00-core/ports.nix"]

{ config, ... }:
let
  # source-id: CFG.server.lanIP
  lanIP = config.my.configs.server.lanIP;
  # source-id: CFG.server.tailscaleIP
  tailscaleIP = config.my.configs.server.tailscaleIP;
  # source-id: CFG.network.dnsDoH
  dnsDoH = config.my.configs.network.dnsDoH;
  # source-id: CFG.network.dnsBootstrap
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
in
{
  # source: my.ports.adguard + my.configs.server.*
  # sink:   services.adguardhome — DNS auf LAN + Tailscale Interface
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = config.my.ports.adguard;
    openFirewall = false;

    settings = {
      dns = {
        # sink: AdGuard lauscht auf Loopback + LAN + Tailscale
        # Kein Hardcode: alle IPs kommen aus 00-core/configs.nix
        bind_hosts = [
          "127.0.0.1"
          lanIP         # sink: CFG.server.lanIP
          tailscaleIP   # sink: CFG.server.tailscaleIP
        ];
        # source-id: CFG.network.dnsDoH
        upstream_dns = dnsDoH;
        # source-id: CFG.network.dnsBootstrap
        bootstrap_dns = dnsBootstrap;
      };
    };
  };
}
```

### ids-report.md aktualisieren

Füge folgende Einträge zu `00-core/ids-report.md` hinzu:

```markdown
## CFG.server.lanIP

Sources:
- /etc/nixos/00-core/configs.nix (neue Option)

Sinks:
- /etc/nixos/10-infrastructure/adguardhome.nix

## CFG.server.tailscaleIP

Sources:
- /etc/nixos/00-core/configs.nix (neue Option)

Sinks:
- /etc/nixos/10-infrastructure/adguardhome.nix
```

---

## AUFGABE 2: IDs-Report — von manuell zu automatisch

### Problem
```
Datei: 00-core/ids-report.json   (manuell gepflegt, VERALTET)
Datei: 00-core/ids-report.md     (manuell gepflegt, aktueller)
```

Das JSON hat leere `sources`-Listen obwohl die Quellen existieren.
Das Markdown ist aktueller aber auch manuell.

**Es gibt bereits einen Hinweis auf ein existierendes Script** — das gilt es zu finden und zu verwenden:
```bash
# Prüfen ob ein grep/scan-Script existiert:
find /etc/nixos -name "*.sh" -o -name "scan*" -o -name "ids*" | head -20
grep -rn "ids-report\|source-id\|CFG\." /etc/nixos/scripts/ 2>/dev/null
```

### Lösung: `scripts/scan-ids.sh` erstellen

Erstelle `/etc/nixos/scripts/scan-ids.sh`:

```bash
#!/usr/bin/env bash
# scripts/scan-ids.sh
# meta:
#   owner: core
#   status: active
#   summary: Scannt alle .nix Dateien nach CFG.* IDs und generiert ids-report.md + ids-report.json
#
# Verwendung: bash /etc/nixos/scripts/scan-ids.sh
# Output: 00-core/ids-report.md und 00-core/ids-report.json (werden überschrieben)

set -euo pipefail

REPO_DIR="/etc/nixos"
REPORT_MD="${REPO_DIR}/00-core/ids-report.md"
REPORT_JSON="${REPO_DIR}/00-core/ids-report.json"

# Alle bekannten CFG-IDs sammeln (aus source-id Kommentaren)
mapfile -t ALL_IDS < <(
  grep -rn "source-id: CFG\." "${REPO_DIR}" \
    --include="*.nix" \
    --include="*.md" \
    | grep -oP 'source-id: \K(CFG\.[^\s]+)' \
    | sort -u
)

echo "Gefundene IDs: ${#ALL_IDS[@]}"

# Markdown generieren
{
  echo "# IDs Report (automatisch generiert)"
  echo ""
  echo "> Generiert von: scripts/scan-ids.sh"
  echo "> Stand: $(date -I)"
  echo ""

  for id in "${ALL_IDS[@]}"; do
    echo "## ${id}"
    echo ""
    echo "Sources:"

    # Quellen: Zeilen mit "source-id: ${id}"
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      echo "- /etc/nixos/${file}:${lineno}"
    done < <(grep -rn "source-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    echo ""
    echo "Sinks:"

    # Sinks: Zeilen wo die CFG-ID als Wert verwendet wird (sink-id Kommentar)
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      echo "- /etc/nixos/${file}:${lineno}"
    done < <(grep -rn "sink.*${id}\|# sink-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    echo ""
  done
} > "${REPORT_MD}"

# JSON generieren
{
  echo "{"
  first=true
  for id in "${ALL_IDS[@]}"; do
    if [ "$first" = true ]; then first=false; else echo ","; fi

    sources=()
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}||")
      lineno=$(echo "$line" | cut -d: -f2)
      sources+=("\"${file}:${lineno}\"")
    done < <(grep -rn "source-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    sinks=()
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}||")
      lineno=$(echo "$line" | cut -d: -f2)
      sinks+=("\"${file}:${lineno}\"")
    done < <(grep -rn "sink.*${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    sources_json=$(IFS=,; echo "${sources[*]:-}")
    sinks_json=$(IFS=,; echo "${sinks[*]:-}")

    printf '  "%s": {\n    "sources": [%s],\n    "sinks": [%s]\n  }' \
      "${id}" "${sources_json}" "${sinks_json}"
  done
  echo ""
  echo "}"
} > "${REPORT_JSON}"

echo "✅ Generiert:"
echo "   ${REPORT_MD}"
echo "   ${REPORT_JSON}"
echo ""
echo "Tipp: In pre-commit hook einbauen oder via nix-deploy aufrufen."
```

```bash
chmod +x /etc/nixos/scripts/scan-ids.sh
```

### In `nix-deploy.sh` integrieren (optional)

Ergänze `/etc/nixos/00-core/scripts/nix-deploy.sh` um einen IDs-Scan-Schritt:

```bash
# Nach dem git-Status-Check, vor dem Build:
if [ -x "${REPO_DIR}/scripts/scan-ids.sh" ]; then
  log "IDs-Report aktualisieren..."
  bash "${REPO_DIR}/scripts/scan-ids.sh"
  # Wenn Änderungen entstanden sind, automatisch stagen:
  if ! git -C "$REPO_DIR" diff --quiet 00-core/ids-report.md; then
    log "IDs-Report hat sich geändert, wird zum Commit hinzugefügt"
    sudo git -C "$REPO_DIR" add 00-core/ids-report.md 00-core/ids-report.json
  fi
fi
```

---

## AUFGABE 3: Weitere hardcodierte Werte identifizieren und zentralisieren

### Scan-Ergebnis aus dem Audit (alle hardcodierten Nicht-Loopback IPs außerhalb von 00-core)

Folgende Dateien müssen geprüft und angepasst werden:

#### `10-infrastructure/wireguard-vpn.nix`
```nix
# AKTUELL hardcodiert (wireguard-spezifisch, darf bleiben aber dokumentieren):
Address = 100.64.4.147/32      # ← WireGuard-Interface-IP (Privado-spezifisch)
DNS = 198.18.0.1,198.18.0.2   # ← Privado DNS
Endpoint = 91.148.237.21:51820 # ← Privado Server-Endpoint
PublicKey = KgTUh...           # ← Privado Peer-Key
```

**Entscheidung:** Diese Werte sind VPN-Provider-spezifisch und gehören in die Secrets-Datei
oder in eine eigene `vpn-config.nix`. Sie sind nicht universell portierbar.

**Empfehlung:**
```nix
# 00-core/configs.nix — neue VPN-Section:
vpn = {
  privado = {
    # source-id: CFG.vpn.privado.address
    address = lib.mkOption {
      type = lib.types.str;
      default = "100.64.4.147/32";
      description = "WireGuard Interface-IP für Privado VPN.";
    };
    # source-id: CFG.vpn.privado.dns
    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "198.18.0.1" "198.18.0.2" ];
      description = "DNS-Server des Privado VPN.";
    };
    # source-id: CFG.vpn.privado.endpoint
    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "91.148.237.21:51820";
      description = "WireGuard Peer-Endpoint für Privado VPN.";
    };
    # source-id: CFG.vpn.privado.publicKey
    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
      description = "WireGuard Peer-PublicKey des Privado-Servers.";
    };
  };
};
```

#### `10-infrastructure/traefik-core.nix`
```nix
# AKTUELL:
http://127.0.0.1:3000   # ← Pocket-ID Port hardcodiert
```

Pocket-ID Port 3000 ist noch nicht in `ports.nix`. Ergänzen:
```nix
# 00-core/ports.nix:
pocketId = 10010;   # oder 3000 beibehalten wenn Standard — aber zentralisieren!
```

Dann in `traefik-core.nix`:
```nix
# source-id: CFG wird über my.ports.pocketId referenziert
address = "http://127.0.0.1:${toString config.my.ports.pocketId}";
```

**Konsistenz prüfen:** `pocket-id.nix` hat ebenfalls `url = "http://127.0.0.1:3000"` hardcodiert.
Beide Dateien müssen denselben Port-Wert aus `ports.nix` verwenden.

---

## AUFGABE 4: `configs.nix` — Sources-Tracking reparieren

### Problem
```
Datei: 00-core/ids-report.json
```
```json
"CFG.identity.domain": {
  "sources": [],   // ← FALSCH: Quelle ist configs.nix:26
```

Nach dem Erstellen des Scan-Scripts (Aufgabe 2) wird dieses Problem automatisch behoben.
Aber die `source-id`-Kommentare müssen korrekt in `configs.nix` selbst stehen:

```nix
# 00-core/configs.nix — Prüfe ob JEDE Option einen source-id Kommentar hat:
options.my.configs = {
  identity = {
    # source-id: CFG.identity.domain  ← MUSS direkt über der Option stehen
    domain = lib.mkOption { ... };

    # source-id: CFG.identity.email
    email = lib.mkOption { ... };

    # source-id: CFG.identity.user
    user = lib.mkOption { ... };

    # source-id: CFG.identity.host
    host = lib.mkOption { ... };
  };
  # ... etc
};
```

**Script ausführen nach Änderungen:**
```bash
bash /etc/nixos/scripts/scan-ids.sh
# Prüfen ob alle IDs jetzt Sources haben:
python3 -c "
import json
with open('/etc/nixos/00-core/ids-report.json') as f:
    data = json.load(f)
for id, info in data.items():
    if not info['sources']:
        print(f'FEHLT SOURCE: {id}')
"
```

---

## AUFGABE 5: Pocket-ID Port-Duplizierung beheben

### Problem
Port 3000 für Pocket-ID ist an **drei** Stellen hardcodiert:
```
10-infrastructure/pocket-id.nix:46:    url = "http://127.0.0.1:3000";
10-infrastructure/traefik-core.nix:103: address = "http://127.0.0.1:3000";
```

### Lösung

**Schritt 1:** Port in `ports.nix` eintragen:
```nix
# 00-core/ports.nix
config.my.ports = {
  # ... bestehende Ports ...
  pocketId = 3000;   # Pocket-ID Default-Port (WebAuthn/OIDC Provider)
};
```

**Schritt 2:** `pocket-id.nix` anpassen:
```nix
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  # source: my.ports.pocketId
  port = config.my.ports.pocketId;
in
{
  services.pocket-id = {
    enable = false;
    # ...
  };

  services.traefik.dynamicConfigOptions.http = {
    # ...
    services."pocket-id" = {
      loadBalancer.servers = [{
        # source: my.ports.pocketId
        url = "http://127.0.0.1:${toString port}";  # kein Hardcode mehr
      }];
    };
  };
}
```

**Schritt 3:** `traefik-core.nix` anpassen:
```nix
# Zeile 103 in traefik-core.nix:
# VORHER:
address = "http://127.0.0.1:3000";

# NACHHER:
# source: my.ports.pocketId
address = "http://127.0.0.1:${toString config.my.ports.pocketId}";
```

---

## CHECKLISTE FÜR DIE AUSFÜHRENDE KI

```bash
# 1. Keine hardcodierten IPs außerhalb von 00-core (außer 127.0.0.1 und VPN-Exceptions):
grep -rn "\b192\.168\.\|100\.\(113\|64\)" \
  /etc/nixos/10-infrastructure/ \
  /etc/nixos/20-services/ \
  --include="*.nix"
# Erwartetes Ergebnis: 0 Treffer (nach der Bereinigung)

# 2. Port 3000 nirgends mehr hardcodiert außer ports.nix:
grep -rn '"3000"\|:3000\b' /etc/nixos/ --include="*.nix" | grep -v "ports\.nix"
# Erwartetes Ergebnis: 0 Treffer

# 3. scan-ids.sh funktioniert:
bash /etc/nixos/scripts/scan-ids.sh
# Alle IDs sollten jetzt Sources haben

# 4. AdGuard startet korrekt nach Änderungen:
sudo nixos-rebuild test
sudo journalctl -u adguardhome -n 30 --no-pager

# 5. DNS funktioniert noch:
dig @127.0.0.1 nixos.org
dig @192.168.2.73 nixos.org   # ← mit tatsächlicher LAN-IP
```

---

*Dieses Prompt-Dokument ist Teil 2 von 3. Weiter mit TEIL 3 (Service-Hardening für alle Services).*
