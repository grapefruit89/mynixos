#!/usr/bin/env bash
set -euo pipefail

repo="/etc/nixos"

switch_mode="prompt"   # prompt|yes|no
run_dry="false"
run_test="true"
run_switch="false"
run_git="true"
run_push="true"
run_ssh="true"

log_file="${XDG_CACHE_HOME:-$HOME/.cache}/nix-deploy.log"
log_dir="$(dirname "$log_file")"
mkdir -p "$log_dir"

log() {
  printf "[%s] %s
" "$(date -Is)" "$*"
}

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
  --no-ssh          Skip ssh-agent auto-start

Logging:
  Log file: $log_file

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
    --no-ssh) run_ssh="false" ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

# tee all output to log
exec > >(tee -a "$log_file") 2>&1

log "nix-deploy start"

ensure_ssh_agent() {
  if [ "$run_ssh" != "true" ]; then
    log "ssh-agent autostart disabled"
    return 0
  fi

  if ssh-add -l >/dev/null 2>&1; then
    log "ssh-agent has keys loaded"
    return 0
  fi

  if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    log "starting ssh-agent"
    eval "$(ssh-agent -s)" >/dev/null
  fi

  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    log "loading ssh key: ~/.ssh/id_ed25519"
    ssh-add "$HOME/.ssh/id_ed25519" || true
  else
    log "WARN: ~/.ssh/id_ed25519 not found"
  fi
}

if [ "$run_dry" = "true" ]; then
  log "Running: nixos-rebuild dry-run"
  sudo nixos-rebuild dry-run
  log "done: dry-run"
  exit 0
fi

if [ "$run_test" = "true" ]; then
  log "Running: nixos-rebuild test (temporary until reboot)"
  sudo nixos-rebuild test
  log "done: test"
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
  log "Running: nixos-rebuild switch (persistent)"
  sudo nixos-rebuild switch
  log "done: switch"
fi

if [ "$run_git" != "true" ]; then
  log "git steps skipped"
  exit 0
fi

if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then
  log "No git changes to commit."
else
  log "Changes detected in $repo."
  read -r -p "Commit message (empty to skip): " msg
  if [ -n "$msg" ]; then
    sudo git -C "$repo" add -A
    sudo git -C "$repo" commit -m "$msg" --no-gpg-sign -n
    log "commit created"
  else
    log "commit skipped"
  fi
fi

if [ "$run_push" != "true" ]; then
  log "push skipped"
  exit 0
fi

ensure_ssh_agent

log "git push"
git -C "$repo" push
log "push done"
