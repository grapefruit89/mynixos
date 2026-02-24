{ lib, config, ... }:
let
  domain = "m7c5.de";
  port = config.my.ports.homepage;
  host = "nix.${domain}";
in
lib.mkIf config.services.traefik.enable {
  # source: my.ports.homepage + host nix.m7c5.de
  # sink:   services.homepage-dashboard + services.traefik.dynamicConfigOptions.http
  services.homepage-dashboard = {
    enable = true;
    openFirewall = false;
    listenPort = port;
    allowedHosts = "${host},localhost:${toString port},127.0.0.1:${toString port}";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.homepage = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "homepage";
    };
    services.homepage.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
