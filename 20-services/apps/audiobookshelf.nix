{ config, ... }:
let
  port = config.my.ports.audiobookshelf;
in
{
  # source: my.ports.audiobookshelf
  # sink:   services.audiobookshelf + traefik router nix-audiobookshelf.m7c5.de
  services.audiobookshelf = { enable = true; inherit port; };

  services.traefik.dynamicConfigOptions.http = {
    routers.audiobookshelf = {
      rule = "Host(`nix-audiobookshelf.m7c5.de`)";
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
