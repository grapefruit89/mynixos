{ config, ... }:
let
  port = config.my.ports.n8n;
in
{
  # source: my.ports.n8n
  # sink:   services.n8n + traefik router nix-n8n.m7c5.de
  services.n8n = {
    enable = true;
    environment.N8N_PORT = toString port;
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
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
