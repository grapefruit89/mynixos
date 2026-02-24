{ lib, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "jellyseerr";
      port = 5055;
      stateOption = "configDir";
      defaultStateDir = "/var/lib/jellyseerr/config";
      supportsUserGroup = false;
    })
  ];
}
