{ config, lib, pkgs, ... }:
let
  serviceMap = import ../../00-core/service-map.nix;
  domain = "m7c5.de";
in
{
  services.audiobookshelf = {
    enable = true;
    dataDir = "audiobookshelf";
    user = "audiobookshelf";
    group = "audiobookshelf";
    port = serviceMap.ports.audiobookshelf;
  };

  # Sicherstellen, dass das Datenverzeichnis existiert und die richtigen Berechtigungen hat
  systemd.tmpfiles.rules = [
    "d /var/lib/audiobookshelf 0755 audiobookshelf audiobookshelf -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.audiobookshelf = {
      rule = "Host(`audiobookshelf.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "audiobookshelf";
    };
    services.audiobookshelf.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString serviceMap.ports.audiobookshelf}";
    }];
  };
}
