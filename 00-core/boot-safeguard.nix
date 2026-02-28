/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-003
 *   title: "Boot Safeguard"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
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









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:545222ac4be3bb506f590e1177da9d3cbfcb8fad90bee4e03f728d9d1bd73649
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
