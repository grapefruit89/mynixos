{ lib, config, ... }:
let
  domain = "m7c5.de";
  port = config.my.ports.homepage;
in
lib.mkIf config.services.traefik.enable {
  services.homepage-dashboard = {
    enable = true;
    openFirewall = false;
    listenPort = port;
    allowedHosts = "homepage.${domain},localhost:${toString port},127.0.0.1:${toString port}";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.homepage = {
      rule = "Host(`homepage.${domain}`)";
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
