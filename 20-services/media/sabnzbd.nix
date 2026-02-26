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

    # Killswitch-ish behavior:
    # - Sabnzbd is tied to wg-quick-privado lifecycle
    # - service traffic is restricted to loopback + privado interface
    systemd.services.sabnzbd = {
      bindsTo = [ "wg-quick-privado.service" ];
      partOf = [ "wg-quick-privado.service" ];
      requires = [ "wg-quick-privado.service" ];
      after = [ "wg-quick-privado.service" ];
      
      serviceConfig = {
        RestrictNetworkInterfaces = [ "lo" "privado" ];

        # [SEC-SABNZBD-VPN-001] DNS-Leak mitigation: systemd-resolved bypassen
        # source-id: CFG.vpn.privado.dns
        Environment = [
          "DNSSERVERS=${lib.concatStringsSep "," config.my.configs.vpn.privado.dns}"
        ];

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
