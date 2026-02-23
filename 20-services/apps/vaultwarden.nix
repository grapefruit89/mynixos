{ ... }:
{
  services.vaultwarden = { enable = true; config.ROCKET_PORT = 2002; };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`nix-vaultwarden.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [
      { url = "http://127.0.0.1:2002"; }
    ];
  };
}
