{ lib, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "jellyseerr";
      port = config.my.ports.jellyseerr;
      stateOption = "configDir";
      defaultStateDir = "/var/lib/jellyseerr/config";
      supportsUserGroup = false;
    })
  ];
}
