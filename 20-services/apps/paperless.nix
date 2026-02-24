{ config, ... }:
let
  port = config.my.ports.paperless;
in
{
  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    inherit port;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.paperless = {
      rule = "Host(`nix-paperless.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "paperless";
    };
    services.paperless.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
