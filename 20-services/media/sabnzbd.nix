{ lib, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "sabnzbd";
      port = 8080;
      stateOption = "configFile";
      defaultStateDir = "/var/lib/sabnzbd";
      statePathSuffix = "sabnzbd.ini";
    })
  ];

  config = {
    users.groups.sabnzbd.gid = lib.mkForce 194;
    users.users.sabnzbd.uid = lib.mkForce 984;
  };
}
