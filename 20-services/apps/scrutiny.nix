{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.scrutiny;
  
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  
  # source-id: CFG.ports.scrutiny
  port = config.my.ports.scrutiny;
in
{
  config = lib.mkIf cfg.enable {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = port;
      };
    };

    # Traefik Integration
    services.traefik.dynamicConfigOptions.http = {
      routers.scrutiny = {
        rule = "Host(`scrutiny.${domain}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = "letsencrypt";
        middlewares = [ "secured-chain@file" ];
        service = "scrutiny";
      };
      services.scrutiny.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString port}";
      }];
    };

    # Scrutiny braucht Zugriff auf /dev/sd* für SMART-Daten
    systemd.services.scrutiny.serviceConfig = {
      DeviceAllow = [ "/dev/sda rw" "/dev/sdb rw" ]; # Erweitere falls nötig
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" ];
    };
  };
}
