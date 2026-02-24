{ ... }:
let
  port = 2007;
in
{
  services.readeck = {
    enable = true;
    settings = {
      server = {
        host = "127.0.0.1";
        port = port;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.readeck = {
      rule = "Host(`nix-readeck.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "readeck";
    };
    services.readeck.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
