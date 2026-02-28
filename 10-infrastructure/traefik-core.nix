{ config, lib, pkgs, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;

  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;

  # source-id: CFG.network.tailnetCidrs
  tailnetCidrs = config.my.configs.network.tailnetCidrs;

  trustedIPs = [
    "127.0.0.1/32"
  ] ++ lanCidrs ++ tailnetCidrs ++ [
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
    enable = config.my.profiles.networking.reverseProxy == "traefik";
    package = pkgs.traefik;
    group = "traefik";
    dataDir = "/var/lib/traefik";
    environmentFiles = [
      config.my.secrets.files.sharedEnv
    ];

    staticConfigOptions = {
      log.level = "INFO";
      accessLog = {
        format = "json";
        fields = {
          defaultMode = "keep";
          names.StartUTC = "drop";
        };
      };
      api = {
        dashboard = true;
        insecure = false;
      };

      certificatesResolvers.letsencrypt.acme = {
        email = config.my.configs.identity.email;
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = config.my.configs.network.acmeResolvers;
        };
      };

      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
          http.tls = {
            options = "default@file";
            # certResolver per Router für Self-Signed Fallback
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
          address = "http://127.0.0.1:${toString config.my.ports.pocketId}";
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

        local-ip-whitelist.ipAllowList.sourceRange =
          [ "127.0.0.0/8" "100.64.0.0/10" "169.254.0.0/16" "fd7a:115c:a1e0::/48" ] ++ lanCidrs ++ tailnetCidrs;

        secure-headers.headers = {
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          frameDeny = true;
          customResponseHeaders = {
            "Content-Security-Policy" = "frame-ancestors 'self' https://*.${domain};";
          };
        };

        rate-limit.rateLimit = {
          average = 50;
          burst = 100;
        };

        fail2ban.plugin.fail2ban = {
          logLevel = "INFO";
          allowlist.ip = [ "127.0.0.1" ] ++ lanCidrs ++ tailnetCidrs;
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
        # Dashboard nutzt SSO + Whitelist
        middlewares = [ "sso-internal@file" ];
        service = "api@internal";
        tls.certResolver = "letsencrypt";
      };

      # Break-Glass (Bypass Auth via Tailscale)
      http.routers.traefik-dashboard-bypass = {
        rule = "Host(`traefik.${domain}`) && ClientIP(`100.64.0.0/10`)";
        entryPoints = [ "websecure" ];
        middlewares = [ "local-ip-whitelist@file" "secure-headers@file" ];
        service = "api@internal";
        priority = 2000;
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

  systemd.services.traefik = lib.mkIf (config.my.profiles.networking.reverseProxy == "traefik") {
    serviceConfig = {
      Environment = [ "TZ=${config.time.timeZone}" ];
      NoNewPrivileges = lib.mkForce true;
      PrivateTmp = lib.mkForce true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [
        config.services.traefik.dataDir
        "/var/log/traefik"
      ];
      ProtectHome = lib.mkForce true;
      ProtectKernelTunables = lib.mkForce true;
      ProtectKernelModules = lib.mkForce true;
      ProtectControlGroups = lib.mkForce true;
      RestrictRealtime = lib.mkForce true;
      RestrictSUIDSGID = lib.mkForce true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    };
  };
}
