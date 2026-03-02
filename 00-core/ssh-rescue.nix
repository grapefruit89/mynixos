/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-026
 *   title: "SSH Rescue"
 *   layer: 00
 * summary: Temporary 5-minute SSH window with password auth for emergency recovery.
 * ---
 */
{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  sshPort = config.my.ports.ssh;
  
  # Recovery Window Dauer (in Sekunden)
  recoveryWindowSeconds = 300;  # 5 Minuten
  
  # Helper-Script für Status-Anzeige
  recoveryStatus = pkgs.writeShellScriptBin "ssh-recovery-status" ''
    #!/usr/bin/env bash
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    # Prüfe ob Recovery-Window aktiv ist
    if systemctl is-active --quiet ssh-recovery-window; then
      REMAINING=$(systemctl show ssh-recovery-window -p ActiveExitTimestampMonotonic --value)
      BOOT_TIME=$(systemctl show ssh-recovery-window -p ActiveEnterTimestampMonotonic --value)
      
      if [ "$REMAINING" != "0" ]; then
        ELAPSED=$(( ($(date +%s%N) - BOOT_TIME) / 1000000000 ))
        REMAINING=$(( ${toString recoveryWindowSeconds} - ELAPSED ))
        
        if [ "$REMAINING" -gt 0 ]; then
          echo -e "''${YELLOW}⏱  SSH Recovery Window: AKTIV''${NC}"
          echo -e "   Verbleibend: ''${REMAINING}s"
          echo -e "   Passwort-Login: ''${GREEN}MÖGLICH''${NC}"
          exit 0
        fi
      fi
    fi
    
    echo -e "''${GREEN}🔒 SSH Recovery Window: INAKTIV''${NC}"
    echo -e "   Passwort-Login: ''${RED}GESPERRT''${NC}"
    echo -e "   Nur SSH-Key funktioniert"
    exit 1
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # SSH BASISKONFIGURATION (Unverändert aus ssh.nix übernommen)
  # ══════════════════════════════════════════════════════════════════════════
  
  # WICHTIG: Dieses Modul erweitert ssh.nix, ersetzt es NICHT!
  # ssh.nix muss weiterhin importiert bleiben.
  
  # ══════════════════════════════════════════════════════════════════════════
  # RECOVERY WINDOW SERVICE
  # ══════════════════════════════════════════════════════════════════════════
  
  systemd.services.ssh-recovery-window = {
    description = "SSH Password Recovery Window (5min after boot)";
    documentation = [ "https://github.com/grapefruit89/mynixos/blob/main/00-core/ssh-rescue.nix" ];
    
    # Lifecycle-Management
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      
      # Keine Root-Rechte nötig (sshd reload macht systemd)
      User = "root";
      Group = "root";
    };
    
    # Recovery-Logik
    script = ''
      set -euo pipefail
      
      echo "🔓 SSH Recovery Window startet (${toString recoveryWindowSeconds}s)"
      
      # 1. Backup der aktuellen SSH-Config
      ${pkgs.coreutils}/bin/cp /etc/ssh/sshd_config /tmp/sshd_config.backup
      
      # 2. Aktiviere Passwort-Login temporär
      ${pkgs.gnused}/bin/sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
      ${pkgs.gnused}/bin/sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
      
      # 3. SSHD neu laden (sanft, keine Disconnects)
      ${pkgs.systemd}/bin/systemctl reload sshd
      
      # Log-Meldung
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "Password auth ENABLED for ${toString recoveryWindowSeconds}s"
      
      # 4. Warte Recovery-Zeitfenster ab
      ${pkgs.coreutils}/bin/sleep ${toString recoveryWindowSeconds}
      
      # 5. Restore Original-Config
      ${pkgs.coreutils}/bin/mv /tmp/sshd_config.backup /etc/ssh/sshd_config
      
      # 6. SSHD erneut laden (deaktiviert Passwort wieder)
      ${pkgs.systemd}/bin/systemctl reload sshd
      
      # Log-Meldung
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "Password auth DISABLED after recovery window"
      
      echo "🔒 SSH Recovery Window geschlossen"
    '';
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # NOTFALL-AKTIVIERUNG (Manuell nach Reboot)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Service: Manuell triggerbar (ohne Boot)
  systemd.services.ssh-recovery-manual = {
    description = "SSH Recovery Window (Manual Trigger)";
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    
    script = ''
      echo "⚠️  NOTFALL-MODUS: SSH Recovery manuell aktiviert"
      
      # Aktiviere Passwort für 10 Minuten (länger als normal)
      ${pkgs.gnused}/bin/sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
      ${pkgs.systemd}/bin/systemctl reload sshd
      
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "MANUAL password auth enabled (10min)"
      
      echo "✅ Passwort-Login aktiv für 10 Minuten"
      echo "   Danach manuell deaktivieren:"
      echo "   sudo systemctl stop ssh-recovery-manual"
      
      sleep 600  # 10 Minuten
      
      # Auto-Deaktivierung
      ${pkgs.gnused}/bin/sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
      ${pkgs.systemd}/bin/systemctl reload sshd
      
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "MANUAL password auth disabled"
    '';
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # SHELL INTEGRATION
  # ══════════════════════════════════════════════════════════════════════════
  
  # Aliase für User
  programs.bash.shellAliases = {
    ssh-recovery-status = "${recoveryStatus}/bin/ssh-recovery-status";
    ssh-recovery-enable = "sudo systemctl start ssh-recovery-manual";
  };
  
  # Helper-Scripts systemweit
  environment.systemPackages = [
    recoveryStatus
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # MOTD INTEGRATION (Warnung beim Login)
  # ══════════════════════════════════════════════════════════════════════════
  
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    # SSH Recovery Status anzeigen (nur bei SSH-Login)
    if [ -n "$SSH_CONNECTION" ]; then
      if ${recoveryStatus}/bin/ssh-recovery-status 2>/dev/null; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  HINWEIS: Recovery-Fenster läuft noch!"
        echo "   Füge JETZT deinen SSH-Key hinzu, wenn du ihn verloren hast:"
        echo ""
        echo "   1. Generiere neuen Key: ssh-keygen -t ed25519"
        echo "   2. Zeige Public Key: cat ~/.ssh/id_ed25519.pub"
        echo "   3. Füge in /etc/nixos/00-core/users.nix hinzu"
        echo "   4. Rebuild: sudo nixos-rebuild switch"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
      fi
    fi
  '';
  
  # ══════════════════════════════════════════════════════════════════════════
  # LOGGING & ALERTS
  # ══════════════════════════════════════════════════════════════════════════
  
  # Service: Log-Monitor (warnt bei verdächtigen Password-Logins)
  systemd.services.ssh-recovery-audit = {
    description = "SSH Recovery Audit Logger";
    
    serviceConfig = {
      Type = "oneshot";
    };
    
    script = ''
      # Prüfe ob Passwort-Logins außerhalb des Recovery-Windows stattfanden
      RECENT_LOGINS=$(${pkgs.systemd}/bin/journalctl -u sshd --since "10 minutes ago" \
        | ${pkgs.gnugrep}/bin/grep "Accepted password" || true)
      
      if [ -n "$RECENT_LOGINS" ]; then
        if ! systemctl is-active --quiet ssh-recovery-window; then
          # Password-Login OHNE aktives Recovery-Window!
          ${pkgs.util-linux}/bin/logger -p auth.warning -t ssh-recovery-audit \
            "SUSPICIOUS: Password login detected outside recovery window!"
          
          echo "🚨 VERDÄCHTIG: Passwort-Login außerhalb des Recovery-Fensters!"
          echo "$RECENT_LOGINS"
        fi
      fi
    '';
  };
  
  # Timer: Stündlich prüfen
  systemd.timers.ssh-recovery-audit = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # SICHERHEITS-ASSERTIONS
  # ══════════════════════════════════════════════════════════════════════════
  
  assertions = [
    {
      assertion = config.services.openssh.enable == true;
      message = "ssh-rescue: SSH-Dienst muss aktiviert sein!";
    }
    {
      assertion = recoveryWindowSeconds >= 60;
      message = "ssh-rescue: Recovery-Window muss mindestens 60s sein (aktuell: ${toString recoveryWindowSeconds}s)";
    }
    {
      assertion = recoveryWindowSeconds <= 600;
      message = "ssh-rescue: Recovery-Window sollte nicht länger als 10min sein (aktuell: ${toString recoveryWindowSeconds}s)";
    }
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # DOKUMENTATION
  # ══════════════════════════════════════════════════════════════════════════
  
  # Info-Service (zeigt Anleitung beim Booten)
  systemd.services.ssh-rescue-info = {
    description = "SSH Rescue Info Banner";
    wantedBy = [ "multi-user.target" ];
    after = [ "ssh-recovery-window.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      ${pkgs.util-linux}/bin/logger -t ssh-rescue "SSH Recovery Window: ${toString recoveryWindowSeconds}s nach Boot"
      
      ${pkgs.coreutils}/bin/cat <<'EOF'
      ╔════════════════════════════════════════════════════════════════╗
      ║  SSH RECOVERY WINDOW AKTIV                                     ║
      ║  ─────────────────────────────────────────────────────────────  ║
      ║  Zeitfenster: ${toString recoveryWindowSeconds} Sekunden nach Boot                       ║
      ║  Passwort-Login: Temporär erlaubt                             ║
      ║                                                                 ║
      ║  NOTFALL-ZUGANG (bei Key-Verlust):                             ║
      ║  1. Innerhalb 5min nach Reboot einloggen (mit Passwort)       ║
      ║  2. Neuen SSH-Key generieren: ssh-keygen -t ed25519           ║
      ║  3. Public Key in /etc/nixos/00-core/users.nix eintragen      ║
      ║  4. sudo nixos-rebuild switch                                  ║
      ║                                                                 ║
      ║  Status prüfen: ssh-recovery-status                            ║
      ║  Manuell aktivieren: ssh-recovery-enable                       ║
      ╚════════════════════════════════════════════════════════════════╝
      EOF
    '';
  };
}

# ══════════════════════════════════════════════════════════════════════════
# USAGE GUIDE
# ══════════════════════════════════════════════════════════════════════════
#
# NORMALER BETRIEB:
#   - Nach Reboot: Erste 5 Minuten Passwort-Login möglich
#   - Danach: Nur noch SSH-Key funktioniert
#
# NOTFALL-SZENARIO (Key verloren):
#   1. Server neu booten (physischer Zugang oder Remote-Management)
#   2. Innerhalb 5 Minuten per SSH mit PASSWORT einloggen
#   3. Neuen SSH-Key generieren:
#      $ ssh-keygen -t ed25519 -C "recovery-key-$(date +%Y%m%d)"
#   4. Public Key in Config eintragen:
#      $ sudo micro /etc/nixos/00-core/users.nix
#      # users.users.moritz.openssh.authorizedKeys.keys = [
#      #   "ssh-ed25519 AAAA... neuer-key"
#      # ];
#   5. Aktivieren:
#      $ sudo nixos-rebuild switch
#   6. Testen (neue SSH-Session):
#      $ ssh moritz@server -i ~/.ssh/id_ed25519
#
# MANUELLER TRIGGER (ohne Reboot):
#   $ sudo systemctl start ssh-recovery-manual
#   (Aktiviert Passwort für 10 Minuten)
#
# STATUS PRÜFEN:
#   $ ssh-recovery-status
#   ⏱  SSH Recovery Window: AKTIV
#   Verbleibend: 237s
#   Passwort-Login: MÖGLICH
#
# MONITORING:
#   $ journalctl -u ssh-recovery-window -f
#   $ journalctl -u ssh-recovery-audit
#
# ══════════════════════════════════════════════════════════════════════════
