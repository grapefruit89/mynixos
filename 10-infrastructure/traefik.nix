{ config, lib, ... }:
let
  domain = "m7c5.de";
in
{
  # Traefik läuft als Herzstück. Token kommt aus /etc/secrets/traefik.env
  systemd.services.traefik.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = lib.mkForce "5s";
    OOMScoreAdjust = -900;
    EnvironmentFile = [ "/etc/secrets/traefik.env" ];
  };

  services.traefik = {
    enable = true;
    dataDir = "/var/lib/traefik";

    staticConfigOptions = {
      log.level = "INFO";
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

    dynamicConfigOptions.http.middlewares.secure-headers.headers = {
      stsSeconds = 31536000;
      stsIncludeSubdomains = true;
      stsPreload = true;
      forceSTSHeader = true;
      contentTypeNosniff = true;
      frameDeny = true;
    };
  };

  # Hinweis: Neue Services bitte mit Prefix "nix-" anlegen (z.B. nix-foo.m7c5.de).
}
