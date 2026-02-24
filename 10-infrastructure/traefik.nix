{ config, lib, ... }:
let
  domain = "m7c5.de";
  secretFile = config.my.secrets.files.sharedEnv;
  cfTokenVar = config.my.secrets.vars.traefikAcmeCloudflareDnsApiTokenVarName;
in
{
  # Traceability:
  # source: ${secretFile}:${cfTokenVar}
  # sink: services.traefik ACME dnsChallenge provider=cloudflare
  systemd.services.traefik.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = lib.mkForce "5s";
    OOMScoreAdjust = -900;
    EnvironmentFile = [ secretFile ];
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

      # HTTPS-only edge: no HTTP entrypoint on :80.
      entryPoints.websecure = {
        address = ":${toString config.my.ports.traefikHttps}";
        http.tls = {
          certResolver = "letsencrypt";
          domains = [{
            main = domain;
            sans = [ "*.${domain}" ];
          }];
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

  # Safety note: the env var name must remain CF_DNS_API_TOKEN.
  # It is enforced centrally in 00-core/secrets.nix.
  assertions = [
    {
      assertion = cfTokenVar == "CF_DNS_API_TOKEN";
      message = "security: Traefik Cloudflare token variable must be CF_DNS_API_TOKEN.";
    }
  ];

  # Hinweis: Neue Services bitte mit Prefix "nix-" anlegen (z.B. nix-foo.m7c5.de).
}
