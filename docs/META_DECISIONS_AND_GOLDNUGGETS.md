# Meta-Dokument: Entscheidungen, Verwerfungen, Goldnuggets

Stand: 2026-02-24
Zweck: Zentrale Entscheidungsübersicht über aktive Doku (`docs/`) plus historisches Material (`docs/archive/`).

## 1) Quellenbasis (Autorität)
1. Aktiv (maßgeblich für Betrieb):
- `docs/PROJECT_VISION_AND_ARCHITECTURE.md`
- `docs/OPEN_ITEMS_NOW.md`
- `docs/SECRETS_BOOTSTRAP.md`
- `docs/SSH_RECOVERY_POLICY.md`
- `docs/OPERATIONS_GITHUB_PUSH.md`
- `docs/NIX_MODULE_CONVENTIONS.md`
- `docs/ARR_API_WIRING.md`

2. Historisch (Ideenspeicher, nicht 1:1 verbindlich):
- `docs/archive/MASTER.md`
- `docs/archive/MASTER (1).md`
- `docs/archive/Claude-NixOS-Masterchat*.md`
- `docs/archive/gemin context.md`

## 2) Architektur- und Betriebsentscheidungen (angenommen)
1. Modularer Aufbau bleibt: `00-core`, `10-infrastructure`, `20-services`, `90-policy`.
Begründung: klare Trennung, wartbar, Assertions zentralisierbar.

2. Guardrail-Ansatz mit Assertions bleibt.
Begründung: verhindert stille Security-Regressions.

3. Zentrale Port-Registry über `my.ports.*` bleibt.
Begründung: kein Hardcode, konsistente Policy-Prüfung.

4. SSH-Notfallpfad bleibt (`PermitTTY`, key-aware Fallback-Logik).
Begründung: Recovery-fähig ohne Daueraufweichung.

5. Betriebsablauf bleibt: `git pull --ff-only` -> `nixos-rebuild test` -> `nixos-rebuild switch`.
Begründung: risikoarme Aktivierung.

6. Secrets kurzfristig über lokale Runtime-ENV-Datei.
Begründung: pragmatisch, schnell deploybar; spätere Migration möglich.

7. Traefik + Cloudflare DNS-Challenge als TLS-Modell bleibt.
Begründung: Wildcard/TLS hinter NAT praktikabel.

8. fail2ban bleibt aktiv.
Begründung: zusätzliche Schutzschicht bei Expositionsfehlern.

## 3) Verworfen / bewusst nicht umgesetzt (inkl. Warum)
1. Vollständige frühe sops-Pflichtmigration (sofort).
Warum verworfen: operative Stabilität zuerst; Komplexität am Anfang reduziert.

2. Breite "alles global öffnen"-Firewallmuster.
Warum verworfen: widerspricht minimaler Angriffsfläche.

3. Komplexe OpenSSH-Match-Negationskonstrukte als Primärschutz.
Warum verworfen: fehleranfällig, potenzielles Lockout-Risiko.

4. Frühzeitige Plattformausweitung (zu viele zusätzliche Services gleichzeitig).
Warum verworfen: erhöht Betriebslast und Fehlerrisiko in der Stabilisierungsphase.

5. Harte Abhängigkeit von Archiv-Texten als direkte Truth-Source.
Warum verworfen: Archive enthalten teils widersprüchliche historische Stände.

## 4) Goldnuggets aus Doku/Archiv (wichtig, noch nicht vollständig umgesetzt)
1. Secrets-Härtung via `sops-nix` als nächster großer Reifegrad.
Nutzen: reproduzierbare, verschlüsselte Secret-Verwaltung statt manueller `.env`-Pflege.
Status: offen (geplant).

2. Konsolidiertes "Decision Log" dauerhaft pflegen.
Nutzen: nachvollziehbar, warum Dinge so und nicht anders gebaut wurden.
Status: mit dieser Datei gestartet, laufend ergänzen.

3. Explizites Operations-Runbook (Incident/Recovery/Rotation).
Nutzen: schnellere Störungsbehebung, weniger Ad-hoc-Kommandos.
Status: teilweise vorhanden, noch nicht als einheitliches Runbook zusammengeführt.

4. Archive-Kuration mit klaren Labels (`authoritative` vs `historical`).
Nutzen: reduziert Fehlentscheidungen auf Basis veralteter Snippets.
Status: begonnen (`docs/archive/CONSOLIDATION_NOTES.md`), weiter ausbauen.

5. Optionaler automatisierter Health-/Preflight-Check vor jedem `switch`.
Nutzen: frühzeitige Erkennung von Drift/Regressionen.
Status: offen.

6. Architekturdiagramm (Ingress -> Proxy -> Services -> Policy).
Nutzen: Onboarding und Review deutlich schneller.
Status: offen.

## 5) Priorisierte Next Steps
1. `Hoch`: Secret-Übergang planen: von `.env` auf `sops-nix` inkl. Rotationsprozess.
2. `Hoch`: Dieses Meta-Dokument bei Architekturänderungen sofort mitpflegen.
3. `Mittel`: Einheitliches `docs/OPERATIONS_RUNBOOK.md` bauen (Recovery, Rollback, Token-Rotation).
4. `Mittel`: Archivdateien mit Kurz-Header versehen (`historical`, Datum, Gültigkeitsbereich).
5. `Niedrig`: Architekturdiagramm ergänzen.

## 6) Pflege-Regeln für dieses Dokument
1. Neue Entscheidung nur mit: Kontext, Entscheidung, Konsequenz.
2. Verwerfung immer mit Grund dokumentieren.
3. Goldnuggets nur aufnehmen, wenn klarer Betriebsnutzen erkennbar ist.
4. Aktive Konfig gewinnt immer gegen Archivtext bei Konflikten.
