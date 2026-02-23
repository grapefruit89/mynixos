{ ... }:
{
  services.sonarr.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.sonarr = {
      rule = "Host(`nix-sonarr.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "sonarr";
    };
    services.sonarr.loadBalancer.servers = [
      { url = "http://127.0.0.1:8989"; }
    ];
  };
}
