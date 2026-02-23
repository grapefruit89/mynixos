{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de"; # Annahme: Domain ist hier definiert, kann bei Bedarf globaler gemacht werden
in
{
  services.homepage = {
    enable = true;
    configDir = "/var/lib/homepage"; # Standard-Pfad für Konfigurationsdateien
    user = "homepage";
    group = "homepage";
    # Optional: Weitere Homepage-spezifische Einstellungen hier.
    # Homepage benötigt normalerweise keine besonderen Einstellungen in NixOS
    # außer der Aktivierung und dem Pfad für die Konfiguration.
  };

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
        url = "http://127.0.0.1:3000"; # Standard-Port für Homepage
      }];
    };
  };
}
