# Operations Runbook

Stand: 2026-02-24

## 1) Standard Deploy (sicher)
```bash
cd /etc/nixos
git fetch origin
git pull --ff-only
sudo nixos-rebuild test
sudo nixos-rebuild switch
```

## 2) Schnelle Gesundheitsprüfung
```bash
sudo systemctl is-active sshd firewall fail2ban traefik
sudo journalctl -u sshd -n 50 --no-pager
sudo journalctl -u traefik -n 50 --no-pager
```

## 3) SSH-Recovery (wenn Login zickt)
1. Lokal am Host einloggen (TTY/Console).
2. Konfig prüfen:
```bash
rg -n "services\.openssh|openFirewall|PasswordAuthentication|KbdInteractiveAuthentication" /etc/nixos/00-core/ssh.nix
```
3. Erst testen, dann switch:
```bash
sudo nixos-rebuild test
sudo nixos-rebuild switch
```
4. Parallel in zweitem Terminal SSH testen, bevor weitere Änderungen folgen.

## 4) Firewall-Recovery
1. Aktuellen Zustand prüfen:
```bash
rg -n "networking\.firewall\.enable" /etc/nixos/00-core/firewall.nix
sudo systemctl status firewall --no-pager
```
2. Bei nötiger Anpassung: Änderung -> `test` -> `switch`.

## 5) Secrets Rotation (ENV-basiert)
1. Datei aktualisieren:
```bash
sudoedit /etc/secrets/homelab-runtime-secrets.env
```
2. Rechte sicherstellen:
```bash
sudo chmod 600 /etc/secrets/homelab-runtime-secrets.env
```
3. Relevante Dienste neu laden:
```bash
sudo systemctl restart traefik
sudo systemctl start arr-wire.service
```
4. Logs prüfen:
```bash
sudo journalctl -u traefik -n 100 --no-pager
sudo journalctl -u arr-wire -n 100 --no-pager
```

## 6) Git-Notfälle
- `non-fast-forward`: erst `git pull --ff-only`, dann erneut pushen.
- Falscher Branch:
```bash
git -C /etc/nixos branch -vv
```

## 7) Rollback
```bash
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
sudo /nix/var/nix/profiles/system-<GEN>-link/bin/switch-to-configuration switch
```

## 8) Minimal-Checkliste vor jeder produktiven Änderung
1. Git sauber?
```bash
git -C /etc/nixos status -sb
```
2. `nixos-rebuild test` erfolgreich?
3. SSH in zweitem Terminal verifiziert?
4. Erst dann `switch`.
