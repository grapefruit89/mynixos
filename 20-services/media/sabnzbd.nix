{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "sabnzbd";
      port = config.my.ports.sabnzbd;
      stateOption = "configFile";
      defaultStateDir = "/var/lib/sabnzbd";
      statePathSuffix = "sabnzbd.ini";
    })
  ];
  config = {
    users.groups.sabnzbd.gid = lib.mkForce 194;
    users.users.sabnzbd.uid = lib.mkForce 984;
    systemd.services.sabnzbd = {
      requires = lib.mkForce [ "wireguard-vault.service" ];
      after = lib.mkForce [ "wireguard-vault.service" ];
    };
  };
}
