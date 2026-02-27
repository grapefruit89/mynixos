#!/usr/bin/env bash
set -euo pipefail

BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$BOOT_USAGE" -ge 85 ]; then
  echo "❌ FEHLER: /boot ist zu ${BOOT_USAGE}% voll!"
  echo ""
  echo "nixos-rebuild wurde abgebrochen, um ein volles /boot zu verhindern."
  echo ""
  echo "Lösung:"
  echo "  1. sudo nix-collect-garbage --delete-older-than 3d"
  echo "  2. sudo nixos-rebuild boot  (keine neue Generation auf /boot)"
  echo "  3. sudo reboot"
  echo "  4. Dann: sudo nix-collect-garbage -d  (löscht alte boot-Einträge)"
  echo ""
  exit 1
fi

echo "✅ /boot Check: OK (${BOOT_USAGE}%)"
