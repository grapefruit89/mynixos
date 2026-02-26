# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Home-Manager Brücke (Importiert User-Profile)

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
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${user} = import (../users + "/${user}/home.nix");
}
