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
 * summary: Prevent /boot overflow with aggressive GC and pre-build checks.
 * ---
 */
{ config, lib, pkgs, ... }:

let
  # Schwellwerte für Warnungen
  warningThreshold = 75;  # % Füllstand
  criticalThreshold = 85; # % Füllstand
  
  # Space-Check Script
  bootSpaceCheck = pkgs.writeShellScriptBin "boot-space-check" ''
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
    if [ "$BOOT_USAGE" -ge ${toString criticalThreshold} ]; then
      echo -e "Status:   ''${RED}KRITISCH''${NC} (''${BOOT_USAGE}%)"
      echo -e "Frei:     ''${RED}''${BOOT_AVAIL}''${NC}"
      echo ""
      echo "🚨 AKTION ERFORDERLICH:"
      echo "   sudo nix-collect-garbage --delete-older-than 3d"
      echo "   sudo nixos-rebuild switch --rollback"
      EXIT_CODE=2
    elif [ "$BOOT_USAGE" -ge ${toString warningThreshold} ]; then
      echo -e "Status:   ''${YELLOW}WARNUNG''${NC} (''${BOOT_USAGE}%)"
      echo -e "Frei:     ''${YELLOW}''${BOOT_AVAIL}''${NC}"
      echo ""
      echo "⚠️  Empfehlung: Alte Generationen löschen"
      echo "   nclean (oder: sudo nix-collect-garbage)"
      EXIT_CODE=1
    else
      echo -e "Status:   ''${GREEN}OK''${NC} (''${BOOT_USAGE}%)"
      echo -e "Frei:     ''${GREEN}''${BOOT_AVAIL}''${NC}"
      EXIT_CODE=0
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Generationen auflisten
    echo ""
    echo "📦 Installierte Generationen:"
    sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -6
    
    exit $EXIT_CODE
  '';
  
  # Pre-Build Hook (verhindert Build bei vollem /boot)
  preBuildCheck = pkgs.writeShellScriptBin "pre-build-check" ''
    #!/usr/bin/env bash
    set -euo pipefail
    
    BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$BOOT_USAGE" -ge ${toString criticalThreshold} ]; then
      echo "❌ FEHLER: /boot ist zu ''${BOOT_USAGE}% voll!"
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
    
    echo "✅ /boot Check: OK (''${BOOT_USAGE}%)"
  '';
  
  # Emergency Cleanup Script
  emergencyCleanup = pkgs.writeShellScriptBin "boot-emergency-cleanup" ''
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "🚨 NOTFALL-CLEANUP für /boot"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Aktuelle Generationen anzeigen
    echo "Vorher:"
    sudo nix-env -p /nix/var/nix/profiles/system --list-generations
    echo ""
    
    # Nur die letzten 3 Generationen behalten
    read -p "Alle außer den letzten 3 Generationen löschen? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
      sudo nix-collect-garbage -d
      
      echo ""
      echo "Nachher:"
      sudo nix-env -p /nix/var/nix/profiles/system --list-generations
      
      echo ""
      echo "✅ Cleanup abgeschlossen"
      echo "   Neuer /boot Füllstand:"
      df -h /boot | tail -1
    else
      echo "Abgebrochen."
    fi
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # KONFIGURATION: Aggressive GC + Generation-Limit
  # ══════════════════════════════════════════════════════════════════════════
  
  # Automatische Garbage Collection (TÄGLICH statt wöchentlich)
  nix.gc = {
    automatic = true;
    dates = lib.mkForce "daily";  # Vorher: "Sun 03:30" (nur 1x pro Woche)
    options = lib.mkForce "--delete-older-than 7d";  # Vorher: 14d
    persistent = true;
  };
  
  # Optimierung nach GC (Deduplizierung)
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];  # 1x pro Woche reicht
  };
  
  # Maximale Anzahl Generationen auf /boot (KRITISCH!)
  boot.loader.systemd-boot.configurationLimit = lib.mkForce 5;
  # ^ Löscht automatisch alte boot-Einträge wenn Limit erreicht
  
  # ══════════════════════════════════════════════════════════════════════════
  # SYSTEMD SERVICES: Monitoring & Pre-Build Check
  # ══════════════════════════════════════════════════════════════════════════
  
  # Service: Täglich Boot-Partition checken
  systemd.services.boot-space-monitor = {
    description = "Boot Partition Space Monitor";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${bootSpaceCheck}/bin/boot-space-check";
      # Bei kritischem Zustand: Alert per Journal
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  
  # Timer: Täglich um 08:00 prüfen
  systemd.timers.boot-space-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "5min";  # Auch 5min nach Boot prüfen
      Persistent = true;
    };
  };
  
  # Service: Pre-Build Check (läuft VOR nixos-rebuild)
  # HINWEIS: Dieser Service wird manuell via Alias aufgerufen
  systemd.services.pre-build-check = {
    description = "Pre-Build Boot Space Check";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${preBuildCheck}/bin/pre-build-check";
    };
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # SHELL INTEGRATION: Warnungen + Helper
  # ══════════════════════════════════════════════════════════════════════════
  
  # Alias für manuellen Check
  programs.bash.shellAliases = {
    boot-check = "${bootSpaceCheck}/bin/boot-space-check";
    boot-emergency = "${emergencyCleanup}/bin/boot-emergency-cleanup";
  };
  
  # Helper-Scripts systemweit verfügbar machen
  environment.systemPackages = [
    bootSpaceCheck
    preBuildCheck
    emergencyCleanup
    (pkgs.writeShellScriptBin "nixos-rebuild-safe" ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      # Pre-Build Check
      if ! ${preBuildCheck}/bin/pre-build-check; then
        echo ""
        echo "Abbruch durch boot-space-check."
        exit 1
      fi
      
      # Original nixos-rebuild aufrufen
      exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild "$@"
    '')
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # ERWEITERTE NIX-EINSTELLUNGEN
  # ══════════════════════════════════════════════════════════════════════════
  
  # Alias: 'nsw-safe' statt 'nsw'
  programs.bash.shellAliases = {
    nsw-safe = "sudo nixos-rebuild-safe switch";
    ntest-safe = "sudo nixos-rebuild-safe test";
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # ASSERTIONS: Sicherheitsprüfungen
  # ══════════════════════════════════════════════════════════════════════════
  
  assertions = [
    {
      assertion = config.boot.loader.systemd-boot.configurationLimit <= 10;
      message = "boot-safeguard: configurationLimit sollte <= 10 sein (aktuell: ${toString config.boot.loader.systemd-boot.configurationLimit})";
    }
    {
      assertion = config.nix.gc.automatic == true;
      message = "boot-safeguard: nix.gc.automatic muss aktiviert sein!";
    }
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # DOKUMENTATION: In-Code Hinweise
  # ══════════════════════════════════════════════════════════════════════════
  
  # Warnung im System-Log bei Boot
  systemd.services.boot-safeguard-info = {
    description = "Boot Safeguard Info Message";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.coreutils}/bin/cat <<'EOF' | ${pkgs.util-linux}/bin/logger -t boot-safeguard
      ╔════════════════════════════════════════════════════════════════╗
      ║  BOOT-SAFEGUARD AKTIV                                          ║
      ║  - Maximale Generationen: ${toString config.boot.loader.systemd-boot.configurationLimit}                                         ║
      ║  - GC-Intervall: täglich                                       ║
      ║  - Monitor: systemctl status boot-space-monitor                ║
      ║  - Manueller Check: boot-check                                 ║
      ║  - Notfall-Cleanup: boot-emergency                             ║
      ╚════════════════════════════════════════════════════════════════╝
      EOF
    '';
  };
}

# ══════════════════════════════════════════════════════════════════════════
# USAGE GUIDE
# ══════════════════════════════════════════════════════════════════════════
#
# MANUELLER CHECK:
#   $ boot-check
#   Status:   OK (67%)
#   Frei:     31M
#
# NOTFALL-CLEANUP (wenn /boot >90% voll):
#   $ boot-emergency
#   (Löscht alle außer den letzten 3 Generationen)
#
# SICHERE REBUILDS:
#   $ nsw-safe    # Statt 'nsw'
#   (Prüft vorher ob /boot voll ist)
#
# MONITORING:
#   $ systemctl status boot-space-monitor
#   $ journalctl -u boot-space-monitor -f
#
# ══════════════════════════════════════════════════════════════════════════
