# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Home-Manager Integration (Nativ als NixOS Modul)

{ config, lib, pkgs, ... }:
let
  user = config.my.configs.identity.user;
in
{
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${user} = {
    home.stateVersion = "24.11";
    
    # Hier kommen später benutzerspezifische Configs rein
    home.packages = with pkgs; [
      # micro # Beispiel
    ];
  };
}
