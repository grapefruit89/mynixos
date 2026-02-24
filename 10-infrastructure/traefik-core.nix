{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
  trustedIPs = [
    "127.0.0.1/32"
    "192.168.0.0/16"
    "172.16.0.0/12"
    "10.0.0.0/8"
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];
in
{
  services.traefik = {
    enable = true;
    package = pkgs.traefik;
    group = "traefik";
    dataDir = "/var/lib/traefik";
    environmentFiles = [
      # Format:
      #   CLOUDFLARE_DNS_API_TOKEN=...
      config.my.secrets.files.sharedEnv
    ];

    staticConfigOptions = {
      log.level = "INFO";
      api = {
        dashboard = true;
        insecure = false;
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "moritzbaumeister@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        # For wildcard certificates use Cloudflare DNS challenge.
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
        };
      };

      entryPoints = {
        websecure = {
          address = ":443";
          http.tls = {
            options = "default@file";
            certResolver = "letsencrypt";
            domains = [{
              main = domain;
              sans = [ "*.${domain}" ];
            }];
          };
          forwardedHeaders.trustedIPs = trustedIPs;
        };
      };

      experimental.plugins = {
        geoblock = {
          moduleName = "github.com/PascalMinder/geoblock";
          version = "v0.3.6";
        };
        fail2ban = {
          moduleName = "github.com/tomMoulard/fail2ban";
          version = "v0.8.1";
        };
        cache = {
          moduleName = "github.com/traefik/plugin-simplecache";
          version = "v0.2.1";
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        "pocket-id-auth".forwardAuth = {
          address = "http://127.0.0.1:3000";
          authResponseHeaders = [ "X-Forwarded-User" ];
        };

        secured-chain.chain.middlewares = [
          "secure-headers"
          "rate-limit"
          "fail2ban"
          "compression"
        ];

        trusted-chain.chain.middlewares = [
          "secure-headers"
          "compression"
        ];

        internal-only-chain.chain.middlewares = [
          "local-ip-whitelist"
          "secure-headers"
          "compression"
        ];

        local-ip-whitelist.ipAllowList.sourceRange = [
          "127.0.0.1/32"
          "192.168.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "100.64.0.0/10"
          "fd7a:115c:a1e0::/48"
        ];

        secure-headers.headers = {
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          frameDeny = true;
        };

        security-headers.headers = {
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          frameDeny = true;
        };

        rate-limit.rateLimit = {
          average = 100;
          burst = 200;
        };

        fail2ban.plugin.fail2ban = {
          logLevel = "INFO";
          allowlist.ip = [ "127.0.0.1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "100.64.0.0/10" ];
          rules = {
            bantime = "3h";
            findtime = "10m";
            maxretry = 5;
            enabled = true;
            statuscode = "400,401,403-499";
          };
        };

        compression.compress = {};
      };

      http.routers.traefik-dashboard = {
        rule = "Host(`traefik.${domain}`)";
        entryPoints = [ "websecure" ];
        middlewares = [ "secured-chain@file" "local-ip-whitelist@file" ];
        service = "api@internal";
        tls.certResolver = "letsencrypt";
      };

      tls.options = {
        default = {
          minVersion = "VersionTLS12";
          sniStrict = true;
          cipherSuites = [
            "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
            "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
            "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
          ];
          curvePreferences = [ "CurveP384" "CurveP256" ];
        };
        modern = {
          minVersion = "VersionTLS13";
          sniStrict = true;
          cipherSuites = [
            "TLS_AES_256_GCM_SHA384"
            "TLS_AES_128_GCM_SHA256"
            "TLS_CHACHA20_POLY1305_SHA256"
          ];
          curvePreferences = [ "CurveP521" "CurveP384" ];
        };
      };
    };
  };
}
