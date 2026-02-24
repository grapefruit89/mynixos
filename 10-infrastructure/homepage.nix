{ config, lib, pkgs, ... }:
let
  serviceMap = import ../00-core/service-map.nix;
  domain = "m7c5.de";
  homepageUser = "homepage";
  homepageGroup = "homepage";
  homepageConfigDir = "/data/state/homepage";
  homepagePort = serviceMap.ports.homepage;
in
{
  # Erstelle einen dedizierten Benutzer und eine Gruppe für den Homepage-Dienst
  users.groups.${homepageGroup} = {};
  users.users.${homepageUser} = {
    isSystemUser = true;
    group = homepageGroup;
    home = homepageConfigDir;
    createHome = true;
  };

  # Definiere den Homepage systemd Dienst
  systemd.services.homepage = {
    enable = true;
    description = "Homepage Dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = homepageUser;
      Group = homepageGroup;
      WorkingDirectory = homepageConfigDir;
      ExecStart = "${pkgs.homepage-dashboard}/bin/homepage --host 127.0.0.1 --port ${toString homepagePort} --config ${homepageConfigDir}";
      Restart = "always";
      RestartSec = "5s";
      Environment = [
        "HOMEPAGE_CONFIG=${homepageConfigDir}"
      ];
    };
  };

  # Stelle sicher, dass das Konfigurationsverzeichnis existiert
  systemd.tmpfiles.rules = [
    "d ${homepageConfigDir} 0755 ${homepageUser} ${homepageGroup} - -"
  ];

  # Traefik Integration für den Homepage-Dienst
  services.traefik.dynamicConfigOptions.http = {
    routers.homepage = {
      rule = "Host(`${domain}`) || Host(`www.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "homepage";
    };
    services.homepage = {
      loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString homepagePort}";
      }];
    };
  };
}
