# Open Items Now (bereinigt)

Stand: 2026-02-24
Quelle: Aktive Konfiguration + kuratierte Inhalte aus `docs/archive/`

## Hoch
- Secrets-Härtung finalisieren: optional Migration von `.env` auf `sops-nix` (inkl. dokumentierter Rotation).
- Cloudflare/TLS-Operations regelmäßig prüfen (Token-Lebenszyklus, ACME-Status, Traefik-Health).

## Mittel
- Archiv konsolidieren: `docs/archive/MASTER.md` als Referenz behalten, redundante Chat-Exporte nur als Rohmaterial markieren.
- Für Archive eine kurze Indexdatei mit Status pflegen: `authoritative` vs `historical`.

## Niedrig
- Optional: zusätzlicher Betriebs-Check als Script (`git pull --ff-only` + `nixos-rebuild test` + Services-Health).

## Bereits umgesetzt in diesem Lauf
- `networking.firewall.enable = true`
- `services.openssh.openFirewall = true` (gewünscht als zusätzlicher Lockout-Schutz)
- MOTD/ToDo-Reminder vorhanden
