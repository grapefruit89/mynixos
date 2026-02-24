{ config, ... }:
let
  port = config.my.ports.vaultwarden;
in
{
  # source: my.ports.vaultwarden
  # sink:   services.vaultwarden + traefik router nix-vaultwarden.m7c5.de
  services.vaultwarden = { enable = true; config.ROCKET_PORT = port; };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`nix-vaultwarden.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
