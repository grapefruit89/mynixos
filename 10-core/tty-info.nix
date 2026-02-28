/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Tty Info
 * TRACE-ID:     NIXH-CORE-007
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:68608938c2baed26626170ee6b6e570f9f314426cf7e2328cc2f4c98e6915723
 */

{ config, pkgs, lib, ... }:

{
  systemd.services.tty-ip-info = {
    description = "Display IP Address on TTY1";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
    
    script = ''
      # Warte kurz, damit mDNS/DHCP Zeit haben
      sleep 2
      
      echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo -e "\033[1;32m🌐 NIXHOME SYSTEM STATUS\033[0m"
      echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      
      echo -e "\n\033[1;34m📍 IPv4 Adressen:\033[0m"
      ${pkgs.iproute2}/bin/ip -4 -o addr show | ${pkgs.gnugrep}/bin/grep -v 'lo' | ${pkgs.gawk}/bin/awk '{print "   • " $2 ": " $4}' | ${pkgs.gnused}/bin/sed 's|/[0-9]*||'
      
      echo -e "\n\033[1;34m🔗 Lokale URLs:\033[0m"
      echo -e "   • http://nixhome.local"
      echo -e "   • http://10.254.0.1 (Notfall-Anker)"
      echo -e "   • http://$(hostname).local"
      
      echo -e "\n\033[1;33m🛠  SSH Zugang:\033[0m"
      echo -e "   ssh ${config.my.configs.identity.user}@10.254.0.1 -p ${toString config.my.ports.ssh}"
      
      echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
    '';
  };
}
