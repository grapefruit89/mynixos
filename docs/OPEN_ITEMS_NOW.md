# Open Items Now (bereinigt)

Stand: 2026-02-24
Quelle: Aktive Konfiguration + kuratierte Inhalte aus `docs/archive/`

## Hoch
- Cloudflare/TLS-Operations regelmäßig prüfen (Token-Lebenszyklus, ACME-Status, Traefik-Health).

## Mittel
- Preflight-Script bei Struktur-/Serviceänderungen nachziehen (`/etc/nixos/scripts/preflight-switch.sh`).

## Niedrig
- Architekturdiagramm in `docs/META_DECISIONS_AND_GOLDNUGGETS.md` aktuell halten.

## Bereits umgesetzt in diesem Lauf
- `networking.firewall.enable = true`
- `services.openssh.openFirewall = true`
- MOTD/ToDo-Reminder vorhanden
- ENV-Secrets-Härtung dokumentiert
- Preflight-Check standardisiert
- Archivdateien mit Kurz-Headern versehen
