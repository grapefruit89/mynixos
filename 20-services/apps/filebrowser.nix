{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.filebrowser;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.filebrowser;
in
{
  config = lib.mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      settings = {
        port = port;
        address = "127.0.0.1";
        root = "/mnt/storage";
      };
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.filebrowser = {
        rule = "Host(`files.${domain}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = "letsencrypt";
        middlewares = [ "secured-chain@file" ];
        service = "filebrowser";
      };
      services.filebrowser.loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString port}";
      }];
    };

    systemd.services.filebrowser.serviceConfig = {
      NoNewPrivileges = lib.mkForce true;
      ProtectHome = lib.mkForce true;
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ 
        "/var/lib/filebrowser"
        "/mnt/storage" 
      ];
    };
  };
}
