# Archive-Quellen: Import-Status

Folgende vom Owner genannten Dateien wurden in dieser Repo-Revision noch nicht gefunden:
- `Claude-NixOS Server mit Infrastructure as Code aufsetzen.md`
- `Claude-GitHub repository access request.md`
- `NixOS-Borrowed-Concepts.txt`
- `NixOS-Master-Blueprint.txt`
- `secrets-setup.sh`
- `q958-nixos-setup.md`
- `NIXOS_MASTER_BRIEFING.md`
- `NIXOS_BRIEFING.md`
- `NixOS-IronicBadger-Analyse.txt`

## Empfehlung
Lege sie unter `docs/archive/` ab (oder `archive/` im Repo-Root), dann können Inhalte systematisch konsolidiert und in `docs/PROJECT_VISION_AND_ARCHITECTURE.md` übernommen werden.


## GitHub sichtbar, lokal nicht vorhanden?
Dann ist dein lokales Repo wahrscheinlich noch nicht auf dem neuesten Stand.

```bash
cd /etc/nixos
git fetch origin
git pull --ff-only
```

Anschließend die Dateien unter `docs/archive/` prüfen.
