{ ... }:
{
  services.jellyfin.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`nix-jellyfin.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "jellyfin";
    };
    services.jellyfin.loadBalancer.servers = [
      { url = "http://127.0.0.1:8096"; }
    ];
  };
}
