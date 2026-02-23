{ ... }:
{
  services.scrutiny = {
    enable = true;
    settings.web.listen.port = 2020;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.scrutiny = {
      rule = "Host(`nix-scrutiny.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "scrutiny";
    };
    services.scrutiny.loadBalancer.servers = [
      { url = "http://127.0.0.1:2020"; }
    ];
  };
}
