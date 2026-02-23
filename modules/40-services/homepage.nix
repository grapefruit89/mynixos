{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de"; # Annahme: Domain ist hier definiert, kann bei Bedarf globaler gemacht werden
  homepageUser = "homepage";
  homepageGroup = "homepage";
  homepageConfigDir = "/var/lib/homepage";
  homepagePort = 3000; # Standard-Port für Homepage
in
{
  # Erstelle einen dedizierten Benutzer und eine Gruppe für den Homepage-Dienst
  users.groups.${homepageGroup} = {};
  users.users.${homepageUser} = {
    isNormalUser = false;
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
      ExecStart = "${pkgs.homepage-dashboard}/bin/homepage --host 0.0.0.0 --port ${toString homepagePort} --config ${homepageConfigDir}"; # Pass den Startbefehl an den Homepage-Dienst an
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
      rule = "Host(`homepage.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "homepage";
    };
    services.homepage = {
      loadBalancer.servers = [{
        url = "http://127.0.0.1:${toString homepagePort}";
      }];
    };
  };
}
