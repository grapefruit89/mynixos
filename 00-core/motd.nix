/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-015
 *   title: "Motd"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, pkgs, ... }:
let
  firewallReminder = if config.networking.firewall.enable then
    "Firewall: AKTIV"
  else
    "WARNUNG: Firewall ist AUS.";
in
{
  environment.etc."motd".text = ''
    q958 Homelab (Symbiosis-Ready)
    ${firewallReminder}
    
    HINWEIS: Falls Hardware nicht erkannt wurde, führe aus:
    sudo nixhome-detect-hw
  '';

  programs.bash.interactiveShellInit = ''
    if [[ $- == *i* ]]; then
      IP=$(hostname -I | awk '{print $1}')
      echo -e "\e[1;32mLocal IP:\e[0m $IP (http://$IP/setup)"
      
      # Prüfen ob HW-Profil existiert
      if [ ! -f /var/lib/nixhome/user-config.json ] || [ "$(cat /var/lib/nixhome/user-config.json)" == "{}" ]; then
         echo -e "\e[1;33m⚠️ Erstboot-Warnung:\e[0m Hardware noch nicht optimiert."
         echo -e "   Führe aus: \e[1;36msudo nixhome-detect-hw\e[0m"
      fi
    fi
  '';
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:1fb34f68795d2f90ef2ac6a352a26943fa1d9fee982c793ed1a2400fdf7bcd84
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
