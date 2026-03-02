---
title: NixOS Homelab Operations & Workflow Runbook
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard (Enriched)
type: Operations Guide
---

# 🛠️ OPERATIONS & WORKFLOW RUNBOOK

## 🚀 Standard-Deployment (Der goldene Pfad)
1. `git pull --ff-only`
2. `sudo /etc/nixos/scripts/preflight-switch.sh`
3. `sudo nixos-rebuild test`
4. `sudo nixos-rebuild switch`

---

## 🔑 Secrets Bootstrap (Erst-Einrichtung)

Wenn das System neu aufgesetzt wird, müssen die Secrets manuell "gebootstrapped" werden:

```bash
# 1. Verzeichnis sicher anlegen
sudo install -d -m 700 /etc/secrets

# 2. Template kopieren
sudo cp /etc/nixos/00-core/secrets.env.example /etc/secrets/homelab-runtime-secrets.env

# 3. Rechte setzen (Streng!)
sudo chown root:root /etc/secrets/homelab-runtime-secrets.env
sudo chmod 600 /etc/secrets/homelab-runtime-secrets.env
```

---

## 🏥 SSH & Firewall Recovery

### Bei Lockout (Kein SSH Zugriff):
1. Lokal am TTY einloggen.
2. SSH-Konfig prüfen: `rg "services.openssh" /etc/nixos/00-core/ssh.nix`.
3. Firewall temporär stoppen (Nur im Notfall!): `sudo systemctl stop nftables`.
4. Fehler korrigieren, `test` fahren, dann erst `switch`.

### Cloudflare Token Check:
Nutze das Script `p-tokens` (Alias für `p-tokens.sh`), um die Gültigkeit deiner API-Schlüssel bei Cloudflare und GitHub in Echtzeit zu prüfen.

---

## 📂 Git Hygiene & Stau-Management
- Nutze niemals `sudo git`.
- Bei "non-fast-forward" Fehlern: `git fetch origin` gefolgt von `git pull --ff-only`.
- Commits sollten immer den betroffenen Layer im Präfix tragen (z.B. `feat(core): add ssh-timeout`).
