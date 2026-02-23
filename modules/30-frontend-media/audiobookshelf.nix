{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  services.audiobookshelf = {
    enable = true;
    dataDir = "/var/lib/audiobookshelf";
    user = "audiobookshelf";
    group = "audiobookshelf";
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
      middlewares = [ "secure-headers@file" ];
      service = "audiobookshelf";
    };
    services.audiobookshelf.loadBalancer.servers = [{
      url = "http://127.0.0.1:8000"; # Default port for Audiobookshelf
    }];
  };
}
