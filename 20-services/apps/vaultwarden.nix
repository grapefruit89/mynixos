{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de"; # Annahme: Domain ist hier definiert, kann bei Bedarf globaler gemacht werden
in
{
  services.vaultwarden = {
    enable = true;
    # Optional: Weitere Vaultwarden-spezifische Einstellungen hier.
    # z.B. rocket = { ip_header = "X-Forwarded-For"; }; wenn Traefik als Reverse Proxy dient
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vaultwarden.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden = {
      loadBalancer.servers = [{
        url = "http://127.0.0.1:8000"; # Standard-Port für Vaultwarden
      }];
    };
  };
}
