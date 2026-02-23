{ ... }:
{
  services.radarr.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.radarr = {
      rule = "Host(`nix-radarr.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "radarr";
    };
    services.radarr.loadBalancer.servers = [
      { url = "http://127.0.0.1:7878"; }
    ];
  };
}
