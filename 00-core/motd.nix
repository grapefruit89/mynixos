/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-015
 *   title: "MOTD & Shell UI"
 *   layer: 00
 * summary: Dynamic login dashboard and shell-environment initialization.
 * ---
 */
{ config, pkgs, ... }:
let
  # sink: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  # sink: CFG.identity.host
  host = config.my.configs.identity.host;
  
  firewallReminder = if config.networking.firewall.enable then
    "Firewall: ACTIVE"
  else
    "WARNING: Firewall is DISABLED.";
in
{
  # ── STATIC MOTD ─────────────────────────────────────────────────────────
  environment.etc."motd".text = ''
    ${host}.${domain} (NMS v2.3 SRE Edition)
    ${firewallReminder}
    
    Standard Port: ${toString config.my.ports.ssh}
    Local Proxy: Caddy (Edge)
  '';

  # ── INTERACTIVE SHELL INIT ──────────────────────────────────────────────
  programs.bash.interactiveShellInit = ''
    if [[ $- == *i* ]]; then
      IP=$(hostname -I | awk '{print $1}')
      # sink: CFG.identity.user
      echo -e "\e[1;32mWelcome back, ${config.my.configs.identity.user}!\e[0m"
      echo -e "\e[1;34mSystem IP:\e[0m $IP"
      
      # Status der kritischen SRE-Dienste anzeigen
      if systemctl is-active --quiet sshd-recovery.service; then
         echo -e "\e[1;31m🚨 RECOVERY WINDOW ACTIVE (Port 2222)\e[0m"
      fi
    fi
  '';
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
