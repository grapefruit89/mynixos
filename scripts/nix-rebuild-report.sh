#!/usr/bin/env bash
# NixOS SRE Blackbox - Automated Build & Diff Reporter
set -euo pipefail

echo "🚀 SRE Blackbox Build started..."

# Pfad zur vorherigen Generation (vor dem Switch)
PREVIOUS_SYSTEM=$(readlink -f /run/current-system)

# Führe den eigentlichen Build durch
echo "==> 1/3: Running nixos-rebuild..."
# Workaround für Git ownership-Problem unter sudo & --impure für sops-nix
sudo git config --global --add safe.directory /etc/nixos
if ! sudo nixos-rebuild --flake /etc/nixos#nixhome --impure "$@"; then
    echo "❌ Build FAILED. No report will be generated."
    exit 1
fi
echo "✅ Build successful."

# Pfad zur neuen Generation
CURRENT_SYSTEM=$(readlink -f /run/current-system)

# Zielverzeichnis (als 'moritz' ausführen, um Berechtigungsprobleme zu vermeiden)
REPORT_DIR="/home/moritz/nix-reports"
sudo -u moritz mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

echo "==> 2/3: Generating nix-diff report..."
DIFF_FILE="$REPORT_DIR/diff-''${TIMESTAMP}.txt"
sudo -u moritz nix-diff "$PREVIOUS_SYSTEM" "$CURRENT_SYSTEM" > "$DIFF_FILE"
echo "✅ Diff report saved to $DIFF_FILE"

echo "==> 3/3: Generating nix-tree report..."
TREE_FILE="$REPORT_DIR/tree-''${TIMESTAMP}.txt"
sudo -u moritz nix-tree "$CURRENT_SYSTEM" > "$TREE_FILE"
echo "✅ Tree report saved to $TREE_FILE"

echo "🏁 SRE Blackbox Build finished."
