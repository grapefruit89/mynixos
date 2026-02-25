{ config, lib, pkgs, ... }:
let
  
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = config.my.ports.vaultwarden;
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
        url = "http://127.0.0.1:${toString config.my.ports.vaultwarden}";
      }];
    };
  };
}
