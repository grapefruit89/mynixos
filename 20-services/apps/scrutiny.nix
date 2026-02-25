{ config, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  port = config.my.ports.scrutiny;
in
{
  # source: my.ports.scrutiny
  # sink:   services.scrutiny + traefik router nix-scrutiny.${domain}
  services.scrutiny = {
    enable = true;
    settings = {
      web.listen = "127.0.0.1:${toString port}";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.scrutiny = {
      rule = "Host(`nix-scrutiny.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "scrutiny";
    };
    services.scrutiny.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
