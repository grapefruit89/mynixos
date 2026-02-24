{ config, ... }:
let
  port = config.my.ports.scrutiny;
in
{
  # source: my.ports.scrutiny
  # sink:   services.scrutiny + traefik router nix-scrutiny.m7c5.de
  services.scrutiny = {
    enable = true;
    settings.web.listen.port = port;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.scrutiny = {
      rule = "Host(`nix-scrutiny.m7c5.de`)";
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
