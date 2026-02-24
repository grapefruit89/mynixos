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

    # Killswitch-ish behavior:
    # - Sabnzbd is tied to wg-quick-privado lifecycle
    # - service traffic is restricted to loopback + privado interface
    systemd.services.sabnzbd = {
      bindsTo = [ "wg-quick-privado.service" ];
      partOf = [ "wg-quick-privado.service" ];
      requires = [ "wg-quick-privado.service" ];
      after = [ "wg-quick-privado.service" ];
      serviceConfig.RestrictNetworkInterfaces = [ "lo" "privado" ];
    };
  };
}
