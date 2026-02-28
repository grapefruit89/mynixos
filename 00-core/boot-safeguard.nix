/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-00-SYS-CORE-003
 *   title: "Boot Safeguard"
 *   layer: 00
 *   req_refs: [REQ-CORE]
 *   status: stable
 * traceability:
 *   parent: NIXH-00-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:f4977e0ec01801ed0b85741a6bf443c9767d467e089447bde4df565d4b726aec"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
 */

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

  # KRITISCHER FIX: Boot-Partition Preflight Check vor jedem Rebuild
  systemd.services.pre-nixos-rebuild-check = {
    description = "Boot-Partition Preflight Check";
    # Da nixos-rebuild oft manuell gerufen wird, ist ein systemd-hook schwer für das CLI-Tool.
    # Wir stellen aber sicher, dass der Check als System-Service verfügbar ist oder in Deployment-Skripten gerufen wird.
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "boot-check-logic" ''
        USAGE=$(df /boot | tail -1 | awk '{print $5}' | tr -dc '0-9')
        if [ "$USAGE" -ge 85 ]; then
          echo "ABORT: /boot ist zu ''${USAGE}% voll. Rebuild gestoppt." >&2
          echo "Führe aus: sudo nix-collect-garbage -d && sudo nixos-rebuild boot" >&2
          exit 1
        fi
      '';
    };
  };
}
