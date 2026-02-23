{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  # 1. Prowlarr-Dienst konfigurieren
  services.prowlarr = {
    enable = true;
    dataDir = "/var/lib/prowlarr"; # Appdata auf der NVMe
    # User und Gruppe werden vom Modul automatisch angelegt
  };

  # 2. Prowlarr über Traefik erreichbar machen und mit Pocket ID absichern
  services.traefik.dynamicConfigOptions.http = {
    routers.prowlarr = {
      rule = "Host(`nix-prowlarr.${domain}`)";
      entryPoints = [ "websecure" ];
      "tls.certResolver" = "letsencrypt";
      middlewares = [
        "pocket-id-auth@file"
        "secure-headers@file"
      ];
      service = "prowlarr";
    };
    services.prowlarr = {
      loadBalancer.servers = [{
        # Prowlarr lauscht standardmäßig auf Port 9696
        url = "http://127.0.0.1:9696";
      }];
    };
  };
}
