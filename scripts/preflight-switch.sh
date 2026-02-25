#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/etc/nixos"
SECRETS_FILE="/etc/secrets/homelab-runtime-secrets.env"

echo "[1/6] git status"
if ! git -C "$REPO_DIR" diff --quiet || ! git -C "$REPO_DIR" diff --cached --quiet; then
  echo "ERROR: Git working tree not clean in $REPO_DIR"
  git -C "$REPO_DIR" status --short
  exit 1
fi

echo "[2/6] required secrets file"
if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "ERROR: Missing $SECRETS_FILE"
  exit 1
fi

echo "[3/6] secrets permissions"
perm="$(stat -c '%a' "$SECRETS_FILE")"
owner="$(stat -c '%U:%G' "$SECRETS_FILE")"
if [[ "$perm" != "600" || "$owner" != "root:root" ]]; then
  echo "ERROR: $SECRETS_FILE must be root:root and 600 (current: $owner $perm)"
  exit 1
fi

echo "[4/6] critical services"
for svc in sshd firewall fail2ban traefik; do
  state="$(systemctl is-active "$svc" || true)"
  if [[ "$state" != "active" ]]; then
    echo "ERROR: service $svc is not active (state=$state)"
    exit 1
  fi
done

echo "[5/6] config dry-activate"
nixos-rebuild dry-activate >/dev/null

echo "[6/6] done"
echo "Preflight OK: safe to run nixos-rebuild switch"
