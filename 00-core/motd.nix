/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        MOTD & Shell Welcome
 * TRACE-ID:     NIXH-CORE-017
 * PURPOSE:      Benutzerbegrüßung, Status-Warnungen (Firewall/Hardware) beim Login.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        00-core
 * STATUS:       Stable
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
