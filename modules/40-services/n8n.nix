{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  services.n8n = {
    enable = true;
  };

  # Traefik Integration für n8n
  services.traefik.dynamicConfigOptions.http = {
    routers.n8n = {
      rule = "Host(`n8n.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "n8n";
    };
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:5678"; # Default port for n8n
    }];
  };
}
