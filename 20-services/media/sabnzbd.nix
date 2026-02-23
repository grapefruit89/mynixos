{ ... }:
{
  services.sabnzbd.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.sabnzbd = {
      rule = "Host(`nix-sabnzbd.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "sabnzbd";
    };
    services.sabnzbd.loadBalancer.servers = [
      { url = "http://127.0.0.1:8080"; }
    ];
  };
}
