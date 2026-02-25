#!/usr/bin/env bash
set -euo pipefail

repo="/etc/nixos"

switch_mode="prompt"   # prompt|yes|no
run_dry="false"
run_test="true"
run_switch="false"
run_git="true"
run_push="true"

usage() {
  cat <<USAGE
Usage: nix-deploy [options]

Workflow (default):
  1) nixos-rebuild test   (active until reboot)
  2) prompt for switch
  3) optional commit + push

Options:
  -h, --help        Show help
  --dry             Only run nixos-rebuild dry-run
  --test            Run nixos-rebuild test (default)
  --no-test         Skip test
  --switch          Run nixos-rebuild switch (no prompt)
  --no-switch       Do not run switch
  --no-git          Skip git add/commit
  --no-push         Skip git push

Notes:
  - test is temporary (reverts on reboot)
  - switch is persistent
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry) run_dry="true"; run_test="false"; run_switch="false" ;;
    --test) run_test="true" ;;
    --no-test) run_test="false" ;;
    --switch) switch_mode="yes" ;;
    --no-switch) switch_mode="no" ;;
    --no-git) run_git="false" ;;
    --no-push) run_push="false" ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

if [ "$run_dry" = "true" ]; then
  echo "Running: nixos-rebuild dry-run"
  sudo nixos-rebuild dry-run
  exit 0
fi

if [ "$run_test" = "true" ]; then
  echo "Running: nixos-rebuild test (temporary until reboot)"
  sudo nixos-rebuild test
fi

if [ "$switch_mode" = "prompt" ]; then
  read -r -p "Switch to persistent config now? [y/N]: " ans
  if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
    run_switch="true"
  else
    run_switch="false"
  fi
elif [ "$switch_mode" = "yes" ]; then
  run_switch="true"
else
  run_switch="false"
fi

if [ "$run_switch" = "true" ]; then
  echo "Running: nixos-rebuild switch (persistent)"
  sudo nixos-rebuild switch
fi

if [ "$run_git" != "true" ]; then
  exit 0
fi

if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then
  echo "No git changes to commit."
else
  echo "Changes detected in $repo."
  read -r -p "Commit message (empty to skip): " msg
  if [ -n "$msg" ]; then
    sudo git -C "$repo" add -A
    sudo git -C "$repo" commit -m "$msg" --no-gpg-sign -n
  fi
fi

if [ "$run_push" != "true" ]; then
  exit 0
fi

# Push must run as user (SSH agent is user-scoped)
if ! ssh-add -l >/dev/null 2>&1; then
  echo "[WARN] SSH agent has no keys loaded. Run: eval \"\$(ssh-agent -s)\"; ssh-add ~/.ssh/id_ed25519"
fi

git -C "$repo" push
