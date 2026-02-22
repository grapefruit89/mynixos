{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  sops.secrets."cloudflare_api_token" = {
    owner = "traefik";
    group = "traefik";
  };
  systemd.services.traefik.serviceConfig.EnvironmentFile = [
    config.sops.secrets."cloudflare_api_token".path
  ];
  services.traefik = {
    enable = true;
    dataDir = "/var/lib/traefik";
    staticConfigOptions = {
      log.level = "DEBUG";
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
      providers.docker = {
        exposedByDefault = false;
      };
    };
    dynamicConfigOptions = {
      http.middlewares = {
        "pocket-id-auth" = {
          forwardAuth = {
            address = "http://127.0.0.1:3000"; # Interne Adresse von Pocket ID
            authResponseHeaders = [ "X-Forwarded-User" ];
          };
        };

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

  # -- ZUR VALIDIERUNG: Ein einfacher 'whoami'-Service --
  # Dieser Container gibt nur Request-Infos aus. Er wird unter whoami.m7c5.de
  # verfügbar gemacht, um zu testen, ob Traefik und Let's Encrypt korrekt funktionieren.
  virtualisation.oci-containers.containers.whoami = {
    image = "traefik/whoami";
    extraOptions = [
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.whoami.rule=Host(`nix-whoami.${domain}`)"
      "--label=traefik.http.routers.whoami.entrypoints=websecure"
      "--label=traefik.http.routers.whoami.tls.certresolver=letsencrypt"
      "--label=traefik.http.routers.whoami.middlewares=secure-headers@file"
      "--label=traefik.http.services.whoami.loadbalancer.server.port=80"
    ];
  };
}
