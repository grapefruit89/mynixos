{ config, lib, pkgs, ... }:
let
  
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
in
{
  services.n8n = {
    enable = true;
    environment = {
      N8N_PORT = toString config.my.ports.n8n;
      N8N_HOST = "127.0.0.1";
    };
  };

  # Traefik Integration für n8n
  services.traefik.dynamicConfigOptions.http = {
    routers.n8n = {
      rule = "Host(`n8n.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "n8n";
    };
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.n8n}";
    }];
  };
}
