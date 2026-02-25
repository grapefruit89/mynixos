# GitHub Push / Sync Cheat Sheet

## A) Lokale Änderungen nach GitHub pushen

```bash
cd /etc/nixos
git status -sb
git add -A
git commit -m "deine nachricht"
git push origin <dein-branch>
```

Wenn du direkt auf `main` arbeitest:

```bash
git push origin main
```

## B) GitHub-Stand lokal holen (wenn GitHub neuer ist)

```bash
cd /etc/nixos
git fetch origin
git pull --ff-only
```

## C) Sichere NixOS-Deploy-Reihenfolge

```bash
cd /etc/nixos
git pull --ff-only
sudo nixos-rebuild test
sudo nixos-rebuild switch
```

## D) Typische Fehlerbilder
- `non-fast-forward`: erst `git pull --ff-only`, dann erneut pushen.
- Falscher Branch: `git branch -vv` prüfen.
- Auth-Probleme: `gh auth status` oder SSH-Key in GitHub prüfen.
