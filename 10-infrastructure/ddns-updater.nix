{ config, ... }:
let
  port = config.my.ports.ddnsUpdater;
in
{
  # Module kept for future use, currently disabled by not importing it in configuration.nix.
  # Traceability:
  # source (future): ddns provider credentials
  # sink (future): services.ddns-updater + Traefik router nix-ddns.m7c5.de
  services.ddns-updater = {
    enable = true;
    environment = {
      LISTENING_ADDRESS = ":${toString port}";
      PERIOD = "10m";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.ddns-updater = {
      rule = "Host(`nix-ddns.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "ddns-updater";
    };
    services.ddns-updater.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
