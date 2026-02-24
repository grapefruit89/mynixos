{ config, lib, pkgs, ... }:
let
  serviceMap = import ../../00-core/service-map.nix;
  domain = "m7c5.de";
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = serviceMap.ports.vaultwarden;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.${domain}`) || Host(`vaultwarden.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden = {
      loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString serviceMap.ports.vaultwarden}";
      }];
    };
  };
}
