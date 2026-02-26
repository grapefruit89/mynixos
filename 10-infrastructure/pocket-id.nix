{ config, lib, ... }:
let
  cfg = config.my.profiles.services.pocket-id;
  
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;

  # source-id: CFG.ports.pocketId
  port = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = "https://auth.${domain}";
        title = "m7c5 Login";
      };
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.pocket-id = {
        rule = "Host(`auth.${domain}`)";
        entryPoints = [ "websecure" ];
        "tls.certResolver" = "letsencrypt";
        middlewares = [ "secure-headers@file" ];
        service = "pocket-id";
      };
      services."pocket-id" = {
        loadBalancer.servers = [{
          url = "http://127.0.0.1:${toString port}";
        }];
      };
    };
  };
}
