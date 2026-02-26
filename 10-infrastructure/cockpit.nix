{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.cockpit;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.cockpit;
in
{
  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      port = port;
      # Cockpit braucht oft TLS direkt, aber wir nutzen Traefik davor
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
        };
      };
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.cockpit = {
        rule = "Host(`admin.${domain}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = "letsencrypt";
        middlewares = [ "secured-chain@file" ];
        service = "cockpit";
      };
      services.cockpit.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString port}";
      }];
    };
  };
}
