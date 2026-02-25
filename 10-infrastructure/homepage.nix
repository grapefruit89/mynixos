{ config, lib, pkgs, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  homepageUser = "homepage";
  homepageGroup = "homepage";
  homepageConfigDir = "/data/state/homepage";
  homepagePort = config.my.ports.homepage;

  localeProfile = config.my.locale.profile;
  homepageLanguage = if localeProfile == "EN" then "en" else "de";
  homepageSettings = pkgs.writeText "homepage-settings.yaml" "language: ${homepageLanguage}\n";
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
      ExecStartPre = "${pkgs.coreutils}/bin/install -D -m 0644 -o ${homepageUser} -g ${homepageGroup} ${homepageSettings} ${homepageConfigDir}/settings.yaml";
      ExecStart = "${pkgs.homepage-dashboard}/bin/homepage --host 127.0.0.1 --port ${toString homepagePort} --config ${homepageConfigDir}";

      # Manual refresh (optional): systemctl restart homepage
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
