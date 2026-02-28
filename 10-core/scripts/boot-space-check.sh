#!/usr/bin/env bash
set -euo pipefail

# Farben für Terminal-Output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Boot-Partition Füllstand ermitteln
BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
BOOT_AVAIL=$(df -h /boot | tail -1 | awk '{print $4}')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Boot-Partition Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Status-Anzeige mit Farben
if [ "$BOOT_USAGE" -ge 85 ]; then
  echo -e "Status:   ${RED}KRITISCH${NC} (${BOOT_USAGE}%)"
  echo -e "Frei:     ${RED}${BOOT_AVAIL}${NC}"
  echo ""
  echo "🚨 AKTION ERFORDERLICH:"
  echo "   sudo nix-collect-garbage --delete-older-than 3d"
  echo "   sudo nixos-rebuild switch --rollback"
  EXIT_CODE=2
elif [ "$BOOT_USAGE" -ge 75 ]; then
  echo -e "Status:   ${YELLOW}WARNUNG${NC} (${BOOT_USAGE}%)"
  echo -e "Frei:     ${YELLOW}${BOOT_AVAIL}${NC}"
  echo ""
  echo "⚠️  Empfehlung: Alte Generationen löschen"
  echo "   nclean (oder: sudo nix-collect-garbage)"
  EXIT_CODE=1
else
  echo -e "Status:   ${GREEN}OK${NC} (${BOOT_USAGE}%)"
  echo -e "Frei:     ${GREEN}${BOOT_AVAIL}${NC}"
  EXIT_CODE=0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Generationen auflisten
echo ""
echo "📦 Installierte Generationen:"
sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -6

exit $EXIT_CODE
