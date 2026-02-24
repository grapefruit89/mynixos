{ config, ... }:
let
  port = config.my.ports.miniflux;
in
{
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:${toString port}";
      CREATE_ADMIN = 0;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.miniflux = {
      rule = "Host(`nix-miniflux.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "miniflux";
    };
    services.miniflux.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
