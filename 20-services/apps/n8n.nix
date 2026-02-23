{ ... }:
{
  services.n8n = {
    enable = true;
    environment.N8N_PORT = "2017";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.n8n = {
      rule = "Host(`nix-n8n.m7c5.de`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "n8n";
    };
    services.n8n.loadBalancer.servers = [
      { url = "http://127.0.0.1:2017"; }
    ];
  };
}
