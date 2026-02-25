{ config, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  port = config.my.ports.readeck;
in
{
  # source: my.ports.readeck
  # sink:   services.readeck + traefik router nix-readeck.${domain}
  services.readeck = {
    enable = true;
    settings = {
      host = "127.0.0.1";
      port = port;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.readeck = {
      rule = "Host(`nix-readeck.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "readeck";
    };
    services.readeck.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
