{ config, ... }:
let
  port = config.my.ports.readeck;
in
{
  # source: my.ports.readeck + /etc/secrets/readeck.env
  # sink:   services.readeck + traefik router nix-readeck.m7c5.de
  services.readeck = {
    enable = true;
    environmentFile = "/etc/secrets/readeck.env";
    settings = {
      main = {
        data_directory = "/var/lib/readeck";
      };
      database = {
        source = "sqlite3:/var/lib/readeck/db.sqlite3";
      };
      server = {
        host = "127.0.0.1";
        inherit port;
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
