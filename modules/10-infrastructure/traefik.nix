{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  sops.secrets."cloudflare_api_token" = {
    owner = "traefik";
    group = "traefik";
  };

  systemd.services.traefik.environment = {
    CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare_api_token".path;
  };

  services.traefik = {
    enable = true;
    dataDir = "/var/lib/traefik";

    staticConfigOptions = {
      api.dashboard = false;

      certificatesResolvers.letsencrypt.acme = {
        email = "moritzbaumeister@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
        };
      };

      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "letsencrypt";
            domains = [{
              main = domain;
              sans = [ "*.${domain}" ];
            }];
          };
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        secure-headers.headers = {
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          frameDeny = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
