{ ... }:
{
  services.audiobookshelf = { enable = true; port = 2001; };

  services.traefik.dynamicConfigOptions.http = {
    routers.audiobookshelf = {
      rule = "Host(`nix-audiobookshelf.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "audiobookshelf";
    };
    services.audiobookshelf.loadBalancer.servers = [
      { url = "http://127.0.0.1:2001"; }
    ];
  };
}
