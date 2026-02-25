# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Login-Hinweise (MOTD), inkl. Firewall-Reminder

{ config, ... }:
let
  firewallReminder = if config.networking.firewall.enable then
    "Firewall: AKTIV"
  else
    "WARNUNG: Firewall ist AUS. TODO: networking.firewall.enable wieder auf true setzen + nixos-rebuild switch.";
in
{
  environment.etc."motd".text = ''
    q958 Homelab
    ${firewallReminder}
  '';
}
