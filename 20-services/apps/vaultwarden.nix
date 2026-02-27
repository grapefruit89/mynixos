{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "vaultwarden";
    useSSO = false;
    description = "Password Manager";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.ports.vaultwarden;
      };
    };

    systemd.services.vaultwarden.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/vaultwarden" ];
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
    };

    services.traefik.dynamicConfigOptions.http.routers.vaultwarden.rule = lib.mkForce "Host(`vault.${config.my.configs.identity.domain}`) || Host(`vaultwarden.${config.my.configs.identity.domain}`)";
  }
]
