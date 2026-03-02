/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-026
 *   title: "SSH Rescue (Emergency Gate)"
 *   layer: 00
 * summary: Temporary 15-minute SSH window with password auth for emergency recovery.
 * ---
 */
{ config, lib, pkgs, ... }:

let
  # sink: CFG.identity.user
  user = config.my.configs.identity.user;
  # sink: PORT.ssh
  sshPort = config.my.ports.ssh;
  
  recoveryWindowSeconds = 900; # 15 Minuten
  
  recoveryStatus = pkgs.writeShellScriptBin "ssh-recovery-status" ''
    #!/usr/bin/env bash
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    if systemctl is-active --quiet sshd-recovery.service; then
      END_TIME=$(systemctl show sshd-recovery.service -p ActiveEnterTimestamp --value)
      echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo -e "🚨 ''${RED}RECOVERY WINDOW AKTIV''${NC}"
      echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo -e "Port:     2222"
      echo -e "Auth:     Passwort erlaubt"
      echo -e "Gestartet: $END_TIME"
      echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
      echo -e "''${GREEN}Normalbetrieb:''${NC} Recovery-Window geschlossen."
    fi
  '';
in
{
  # ── RECOVERY WINDOW LOGIK ───────────────────────────────────────────────
  # Startet ein zweites SSH-Fenster auf Port 2222 beim Booten.
  systemd.services.sshd-recovery = {
    description = "SSH Recovery Window (Temporary Password Auth)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -p 2222 -o PasswordAuthentication=yes -o PermitRootLogin=no";
      KillMode = "process";
      Restart = "no";
    };

    # Automatischer Timer zum Schließen des Fensters
    postStart = ''
      (sleep ${toString recoveryWindowSeconds} && systemctl stop sshd-recovery.service) &
    '';
  };

  environment.systemPackages = [ recoveryStatus ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
