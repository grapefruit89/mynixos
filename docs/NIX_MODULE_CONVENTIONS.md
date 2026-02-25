# Nix-Modul-Konventionen (isomorph & wartbar)

Diese Konventionen standardisieren Aufbau, Benennung und Kommentare für alle `.nix`-Module im Repo.

## 1) Einheitlicher Metadaten-Header
Ein Header als Kommentar ist sinnvoll: er ist tooling-neutral, stört Nix nicht und hilft beim Onboarding.

Empfohlenes Template (am Dateianfang):

```nix
# meta:
#   owner: core|infra|media|apps|policy
#   status: active|draft|placeholder
#   scope: host|service|shared
#   summary: Kurzbeschreibung in 1 Zeile
#   dependsOn: ["relative/path.nix", "..."]   # optional
#   specIds: ["SEC-..."]                       # optional
```

## 2) Modul-Reihenfolge (Best Practice)
1. `let`-Block (nur wenn nötig)
2. `options` (falls Modul eigene Optionen bereitstellt)
3. `config` (mit `mkIf`-Gates)
4. Assertions (früh, präzise Fehlermeldungen)
5. Traceability-Kommentare (`source`/`sink`) nur bei sicherheits- oder secrets-relevanten Flows

## 3) Bezeichner
- Optionen immer unter `my.<domain>.<name>`
- bools: `enable`
- Hostname/FQDN: `host`/`domain`
- Ports: ausschließlich aus `my.ports.*`

## 4) Kommentarregeln
- Kein veralteter Pfad im Kopfkommentar.
- Keine „historischen“ Verweise auf nicht existierende Strukturen.
- Bei Platzhaltern klarer Status: `status: placeholder` + nächster Schritt.

## 5) Sicherheitsrelevante Variablen
Für Cloudflare DNS-01 mit Traefik/lego gilt als Standard:
- `CLOUDFLARE_DNS_API_TOKEN`

Wenn Legacy-Variablen existieren, nur bewusst und dokumentiert verwenden.


## 6) Schnellstart-Template
- Nutze `00-core/dummy.nix` als Kopiervorlage für neue Module.


## 7) Spec-IDs & Traceability
- Sicherheitskritische Regeln erhalten IDs (z. B. `SEC-SSH-TTY-001`).
- IDs gehören in:
  - Doku (`90-policy/spec-registry.md`)
  - Code-Kommentare
  - Assertion-Messages
- Query-Pattern:
  - `rg -n "\[SEC-" 00-core 10-infrastructure 20-services 90-policy docs`
