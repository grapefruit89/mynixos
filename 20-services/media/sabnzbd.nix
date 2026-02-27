{ lib, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
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

    # Netns Integration via _lib.nix
    systemd.services.sabnzbd = {
      # No longer binding to wg-quick-privado as we use wireguard-vault in netns
      requires = lib.mkForce [ "wireguard-vault.service" ];
      after = lib.mkForce [ "wireguard-vault.service" ];
      
      serviceConfig = {
        # [SEC-SABNZBD-SVC-001] Härtung
        NoNewPrivileges = lib.mkForce true;
        PrivateTmp = lib.mkForce true;
        PrivateDevices = lib.mkForce true;
        ProtectSystem = lib.mkForce "strict";
        ReadWritePaths = [
          "/var/lib/sabnzbd"
          "/data/downloads"
        ];
        ProtectHome = lib.mkForce true;
        ProtectKernelTunables = lib.mkForce true;
        ProtectKernelModules = lib.mkForce true;
        RestrictSUIDSGID = lib.mkForce true;
      };
    };
  };
}
