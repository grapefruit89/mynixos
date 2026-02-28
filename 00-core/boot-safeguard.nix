# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Boot-Partition Safeguard – NVRAM-schonend (3 Generationen)
#   priority: P0 (Blocker)

{ config, lib, pkgs, ... }:

let
  # Schwellwerte für 1000MB Partition (in Prozent)
  warningThreshold = 70; # Warnung ab 700MB belegt
  criticalThreshold = 90; # Kritisch ab 900MB belegt
  
  bootSpaceCheck = pkgs.writeShellScriptBin "boot-space-check" ''
    #!/usr/bin/env bash
    set -euo pipefail
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
    BOOT_AVAIL=$(df -h /boot | tail -1 | awk '{print $4}')
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Boot-Partition Status (Limit: 3 Gens)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ "$BOOT_USAGE" -ge 90 ]; then
      echo -e "Status:   ''${RED}KRITISCH''${NC} (''${BOOT_USAGE}%)"
      EXIT_CODE=2
    elif [ "$BOOT_USAGE" -ge 70 ]; then
      echo -e "Status:   ''${YELLOW}WARNUNG''${NC} (''${BOOT_USAGE}%)"
      EXIT_CODE=1
    else
      echo -e "Status:   ''${GREEN}OK''${NC} (''${BOOT_USAGE}%)"
      EXIT_CODE=0
    fi
    echo -e "Frei:     ''${BOOT_AVAIL}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit $EXIT_CODE
  '';
in
{
  # Konfiguration für NVRAM-Schonung (Claude-Empfehlung)
  boot.loader.systemd-boot.configurationLimit = lib.mkForce 3;
  boot.loader.systemd-boot.editor = false; # Verhindert Manipulation

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Aggressiveres Aufräumen
    persistent = true;
  };

  environment.systemPackages = [ bootSpaceCheck ];

  programs.bash.shellAliases = {
    boot-check = "${bootSpaceCheck}/bin/boot-space-check";
  };
}
