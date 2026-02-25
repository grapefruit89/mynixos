{ config, ... }:
let
  # source-id: CFG.identity.domain
  # sink: issuer URL + traefik host rule
  domain = config.my.configs.identity.domain;

  # source-id: CFG.ports.pocketId
  # sink: Pocket-ID backend URL behind traefik
  port = config.my.ports.pocketId;
in
{
  services.pocket-id = {
    enable = false;
    dataDir = "/var/lib/pocket-id";
    settings = {
      issuer = "https://nix-auth.${domain}";
      title = "m7c5 Login";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.pocket-id = {
      rule = "Host(`nix-auth.${domain}`)";
      entryPoints = [ "websecure" ];
      "tls.certResolver" = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "pocket-id";
    };
    services."pocket-id" = {
      loadBalancer.servers = [{
        # source-id: CFG.ports.pocketId
        # sink: traefik service upstream URL
        url = "http://127.0.0.1:${toString port}";
      }];
    };
  };
}
