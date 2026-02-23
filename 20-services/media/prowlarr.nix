{ ... }:
{
  services.prowlarr.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.prowlarr = {
      rule = "Host(`nix-prowlarr.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "prowlarr";
    };
    services.prowlarr.loadBalancer.servers = [
      { url = "http://127.0.0.1:9696"; }
    ];
  };
}
