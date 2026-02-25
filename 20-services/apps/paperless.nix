{ config, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  port = config.my.ports.paperless;
in
{
  # source: my.ports.paperless
  # sink:   services.paperless + traefik router nix-paperless.${domain}
  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = port;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.paperless = {
      rule = "Host(`nix-paperless.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "paperless";
    };
    services.paperless.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
