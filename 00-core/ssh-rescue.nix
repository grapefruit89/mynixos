/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-026
 *   title: "Ssh Rescue"
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
  user = config.my.configs.identity.user;
  sshPort = config.my.ports.ssh;
  
  # Recovery Window Dauer (in Sekunden)
  recoveryWindowSeconds = 900;  # 15 Minuten (Breaking Glass)
  
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
      echo -e "''${YELLOW}⏱  SSH Recovery Window: AKTIV''${NC}"
      echo -e "   Passwort-Login: ''${GREEN}MÖGLICH''${NC}"
      exit 0
    fi
    
    echo -e "''${GREEN}🔒 SSH Recovery Window: INAKTIV''${NC}"
    echo -e "   Passwort-Login: ''${RED}GESPERRT''${NC}"
    echo -e "   Nur SSH-Key funktioniert"
    exit 1
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # RECOVERY WINDOW SERVICE
  # ══════════════════════════════════════════════════════════════════════════
  
  systemd.services.ssh-recovery-window = {
    description = "SSH & Avahi Recovery Window (15min after boot)";
    documentation = [ "https://github.com/grapefruit89/mynixos/blob/main/00-core/ssh-rescue.nix" ];
    
    # Lifecycle-Management
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      Group = "root";
    };
    
    # Recovery-Logik: Separater SSHD auf Port 2222 (NixOS-Safe) + Firewall Rules
    script = ''
      set -euo pipefail
      
      echo "🔓 SSH & Avahi Recovery Window startet (${toString recoveryWindowSeconds}s)"
      
      # 1. Öffne Notfall-Ports via nftables
      ${pkgs.nftables}/bin/nft add rule inet filter input tcp dport 2222 accept comment "Recovery SSH"
      ${pkgs.nftables}/bin/nft add rule inet filter input udp dport 5353 accept comment "Recovery Avahi"

      # 2. Provisorische Config für den Rettungs-SSHD
      TEMP_CONFIG=$(mktemp)
      cat > "$TEMP_CONFIG" <<EOF
Port 2222
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PasswordAuthentication yes
KbdInteractiveAuthentication yes
PermitRootLogin no
AllowUsers ${user}
EOF

      # 3. Rettungs-SSHD starten
      ${pkgs.openssh}/bin/sshd -f "$TEMP_CONFIG" -D &
      RECOVERY_PID=$!
      
      # Log-Meldung
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "Password auth ENABLED on Port 2222 (PID $RECOVERY_PID)"
      
      # Countdown auf TTY1
      (
        for i in $(${pkgs.coreutils}/bin/seq ${toString recoveryWindowSeconds} -1 1); do
          echo -ne "\r\033[K\033[1;33m⚠️  SSH Recovery: $i s verbleibend... (Port 2222 PASSWORT + Avahi)\033[0m " > /dev/tty1
          ${pkgs.coreutils}/bin/sleep 1
        done
        echo -e "\n\033[1;32m🔒 SSH Recovery Fenster geschlossen.\033[0m" > /dev/tty1
      ) &
      
      # 4. Warten
      ${pkgs.coreutils}/bin/sleep ${toString recoveryWindowSeconds}
      
      # 5. Aufräumen
      kill $RECOVERY_PID || true
      rm -f "$TEMP_CONFIG"
      
      # Lösche die temporären nftables Regeln
      ${pkgs.nftables}/bin/nft delete rule inet filter input tcp dport 2222 || true
      
      ${pkgs.util-linux}/bin/logger -t ssh-recovery "Password auth DISABLED after recovery window"
      echo "🔒 SSH Recovery Window geschlossen"
    '';
  };
  
  # Manuelle Notfall-Aktivierung (Port 2222)
  systemd.services.ssh-recovery-manual = {
    description = "SSH Recovery Window (Manual Trigger)";
    
    serviceConfig = {
      Type = "oneshot";
    };
    
    script = ''
      echo "⚠️  NOTFALL-MODUS: SSH Recovery manuell aktiviert auf Port 2222"
      
      ${pkgs.nftables}/bin/nft add rule inet filter input tcp dport 2222 accept comment "Manual Recovery SSH"
      
      TEMP_CONFIG=$(mktemp)
      cat > "$TEMP_CONFIG" <<EOF
Port 2222
PasswordAuthentication yes
KbdInteractiveAuthentication yes
AllowUsers ${user}
EOF
      ${pkgs.openssh}/bin/sshd -f "$TEMP_CONFIG" -D &
      RECOVERY_PID=$!
      
      echo "✅ Passwort-Login aktiv auf Port 2222 für 15 Minuten"
      sleep 900
      kill $RECOVERY_PID || true
      rm -f "$TEMP_CONFIG"
      ${pkgs.nftables}/bin/nft delete rule inet filter input tcp dport 2222 || true
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
      assertion = recoveryWindowSeconds <= 900;
      message = "ssh-rescue: Recovery-Window sollte nicht länger als 15min sein (aktuell: ${toString recoveryWindowSeconds}s)";
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
      ║  SSH RECOVERY WINDOW AKTIV (Port 2222 + Avahi)                 ║
      ║  ─────────────────────────────────────────────────────────────  ║
      ║  Zeitfenster: 15 Minuten nach Boot                             ║
      ║  Passwort-Login: Temporär erlaubt auf Port 2222               ║
      ║                                                                 ║
      ║  NOTFALL-ZUGANG (bei Key-Verlust):                             ║
      ║  1. Innerhalb 15min nach Reboot einloggen                     ║
      ║     ssh -p 2222 moritz@nixhome.local                           ║
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












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8bf7e6c1e821a37b275ddf26ed4a9e4b0b4807769498d60b6e78fdaf7f0c8404
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
