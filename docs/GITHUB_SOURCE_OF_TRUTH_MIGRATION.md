# Einmalig: Source-of-Truth von lokaler Maschine auf GitHub drehen

## Ziel
Dein produktiver Stand soll aus GitHub kommen; der Server zieht nur noch `git pull` + `nixos-rebuild`.

## Vorgehen (einmalig)
1. Backup vom aktuellen Zustand:
   - `sudo cp -a /etc/nixos /etc/nixos.backup.$(date +%F-%H%M)`
2. Remote prüfen:
   - `cd /etc/nixos && git remote -v`
3. Lokale Änderungen sichern:
   - `cd /etc/nixos && git add -A && git commit -m "pre-migration local snapshot"`
4. GitHub als führenden Stand ziehen:
   - `cd /etc/nixos && git fetch origin`
   - `cd /etc/nixos && git reset --hard origin/<dein-branch>`
5. Build/Test:
   - `cd /etc/nixos && sudo nixos-rebuild test`
6. Persistieren:
   - `cd /etc/nixos && sudo nixos-rebuild switch`

## Betriebsmodell danach
- Änderungen über PRs nach GitHub mergen.
- Auf dem Server nur:
  - `cd /etc/nixos && git pull --ff-only`
  - `sudo nixos-rebuild switch`

## Optional absichern
- Branch-Protection + required checks auf GitHub aktivieren.
- Lokale Direkt-Commits auf `main` vermeiden.
