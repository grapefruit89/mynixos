# Vorschläge aus Codebasis-Review

## 1) Aufgabe: Tippfehler in Modul-Kopfkommentar korrigieren
**Betroffene Datei:** `20-services/apps/netdata.nix`

Im Kopfkommentar steht derzeit der Pfad `modules/40-services/netdata.nix`, obwohl die Datei im Repository unter `20-services/apps/netdata.nix` liegt. Das wirkt wie ein Copy/Paste-Tippfehler und erschwert Navigation sowie Suche.

**Vorschlag für Task:**
- Kopfkommentar auf den realen Pfad korrigieren.
- Optional: Kommentarformat auf die restlichen Module angleichen.

## 2) Aufgabe: Programmierfehler in Cloudflared-/Traefik-Bridge beheben
**Betroffene Datei:** `10-infrastructure/cloudflared-tunnel.nix`

`wildcardPrefix` ist standardmäßig auf `nix-*` gesetzt und wird direkt in einen Hostnamen interpoliert (`"${cfg.wildcardPrefix}.${cfg.domain}"`). Das ergibt effektiv `nix-*.m7c5.de` als Match-Pattern bzw. SNI-Bezug in `originServerName`. Dieses Muster ist für klassische Wildcard-DNS/Host-Matches unüblich und fehleranfällig (üblich ist `*.domain`).

**Vorschlag für Task:**
- Datenmodell trennen in `subdomainPattern` (z. B. `*.m7c5.de`) und optionalen Namenspräfix für Routing-Logik.
- Für `originServerName` einen konkreten Hostnamen verwenden (ohne `*`).
- Mit realen FQDNs (`nix-whoami.m7c5.de` etc.) gegenvalidieren.

## 3) Aufgabe: Kommentar-/Doku-Unstimmigkeit bereinigen
**Betroffene Datei:** `20-services/apps/netdata.nix`

Der Kommentar fordert „Import in `hosts/q958/default.nix` ergänzen“, aber eine solche Struktur ist in der aktiven Root-Konfiguration nicht ersichtlich; stattdessen wird zentral über `configuration.nix` importiert.

**Vorschlag für Task:**
- Kommentar auf den aktuellen Importpfad/Workflow aktualisieren (z. B. `configuration.nix`).
- Falls ein Host-spezifischer Einstieg geplant ist, die Zielstruktur kurz dokumentieren.

## 4) Aufgabe: Tests verbessern (Policy-Regression verhindern)
**Betroffene Dateien:**
- `10-infrastructure/tailscale-policy.current.hujson`
- `10-infrastructure/tailscale-policy.target.hujson`

In der aktuellen Policy sind Beispiel-Tests auskommentiert, während die Ziel-Policy bereits echte `tests` enthält.

**Vorschlag für Task:**
- In der aktuellen Policy ebenfalls produktionsnahe `tests` aktivieren.
- Mindestens 1 Positiv- und 1 Negativfall (z. B. Zugriff auf `tag:infra:22/443`).
- Optional CI/Pre-Commit-Check ergänzen, der Policy-Syntax und Testblöcke validiert.
