{ config, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  port = config.my.ports.miniflux;
in
{
  # source: my.ports.miniflux
  # sink:   services.miniflux + traefik router nix-miniflux.${domain}
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:${toString port}";
      CREATE_ADMIN = 0;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.miniflux = {
      rule = "Host(`nix-miniflux.${domain}`)";
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
