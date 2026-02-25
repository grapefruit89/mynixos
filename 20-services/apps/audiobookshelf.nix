{ config, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  port = config.my.ports.audiobookshelf;
in
{
  # source: my.ports.audiobookshelf
  # sink:   services.audiobookshelf + traefik router nix-audiobookshelf.${domain}
  services.audiobookshelf = {
    enable = true;
    host = "127.0.0.1";
    port = port;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.audiobookshelf = {
      rule = "Host(`nix-audiobookshelf.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "audiobookshelf";
    };
    services.audiobookshelf.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
