/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-031
 *   title: "Tty Info"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:3df47b9df44296576712748af15a6f0e2d7133406d55c703112f776f530b412b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
