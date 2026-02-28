/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Traefik Core Configuration
 * TRACE-ID:     NIXH-INF-001
 * PURPOSE:      Main Reverse-Proxy (TLS, ACME, Cloudflare, Middleware Chains).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable (Legacy Support)
 */

{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanCidrs = config.my.configs.network.lanCidrs;
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
  services.traefik.enable = config.my.profiles.networking.reverseProxy == "traefik";
  services.traefik.package = pkgs.traefik;
  services.traefik.group = "traefik";
  services.traefik.dataDir = "/var/lib/traefik";
  services.traefik.environmentFiles = [
    config.my.secrets.files.sharedEnv
  ];

  services.traefik.staticConfigOptions.log.level = "INFO";
  services.traefik.staticConfigOptions.accessLog.format = "json";
  services.traefik.staticConfigOptions.accessLog.fields.defaultMode = "keep";
  services.traefik.staticConfigOptions.accessLog.fields.names.StartUTC = "drop";
  
  services.traefik.staticConfigOptions.api.dashboard = true;
  services.traefik.staticConfigOptions.api.insecure = false;

  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.email = config.my.configs.identity.email;
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.storage = "${config.services.traefik.dataDir}/acme.json";
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider = "cloudflare";
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.resolvers = config.my.configs.network.acmeResolvers;

  services.traefik.staticConfigOptions.entryPoints.web.address = ":80";
  services.traefik.staticConfigOptions.entryPoints.websecure.address = ":443";
  services.traefik.staticConfigOptions.entryPoints.websecure.http.tls.options = "default@file";
  services.traefik.staticConfigOptions.entryPoints.websecure.forwardedHeaders.trustedIPs = trustedIPs;

  services.traefik.staticConfigOptions.experimental.plugins.geoblock.moduleName = "github.com/PascalMinder/geoblock";
  services.traefik.staticConfigOptions.experimental.plugins.geoblock.version = "v0.3.6";
  services.traefik.staticConfigOptions.experimental.plugins.fail2ban.moduleName = "github.com/tomMoulard/fail2ban";
  services.traefik.staticConfigOptions.experimental.plugins.fail2ban.version = "v0.8.1";
  services.traefik.staticConfigOptions.experimental.plugins.cache.moduleName = "github.com/traefik/plugin-simplecache";
  services.traefik.staticConfigOptions.experimental.plugins.cache.version = "v0.2.1";

  services.traefik.dynamicConfigOptions.http.middlewares."pocket-id-auth".forwardAuth.address = "http://127.0.0.1:${toString config.my.ports.pocketId}";
  services.traefik.dynamicConfigOptions.http.middlewares."pocket-id-auth".forwardAuth.authResponseHeaders = [ "X-Forwarded-User" ];

  services.traefik.dynamicConfigOptions.http.middlewares.secured-chain.chain.middlewares = [
    "secure-headers"
    "rate-limit"
    "fail2ban"
    "compression"
  ];

  services.traefik.dynamicConfigOptions.http.middlewares.trusted-chain.chain.middlewares = [
    "secure-headers"
    "compression"
  ];

  services.traefik.dynamicConfigOptions.http.middlewares.internal-only-chain.chain.middlewares = [
    "local-ip-whitelist"
    "secure-headers"
    "compression"
  ];

  services.traefik.dynamicConfigOptions.http.middlewares.local-ip-whitelist.ipAllowList.sourceRange =
    [ "127.0.0.0/8" "100.64.0.0/10" "169.254.0.0/16" "fd7a:115c:a1e0::/48" ] ++ lanCidrs ++ tailnetCidrs;

  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.stsSeconds = 31536000;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.stsIncludeSubdomains = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.stsPreload = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.forceSTSHeader = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.browserXssFilter = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.contentTypeNosniff = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.frameDeny = true;
  services.traefik.dynamicConfigOptions.http.middlewares.secure-headers.headers.customResponseHeaders."Content-Security-Policy" = "frame-ancestors 'self' https://*.${domain};";

  services.traefik.dynamicConfigOptions.http.middlewares.rate-limit.rateLimit.average = 50;
  services.traefik.dynamicConfigOptions.http.middlewares.rate-limit.rateLimit.burst = 100;

  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.logLevel = "INFO";
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.allowlist.ip = [ "127.0.0.1" ] ++ lanCidrs ++ tailnetCidrs;
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.rules.bantime = "3h";
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.rules.findtime = "10m";
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.rules.maxretry = 5;
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.rules.enabled = true;
  services.traefik.dynamicConfigOptions.http.middlewares.fail2ban.plugin.fail2ban.rules.statuscode = "400,401,403-499";

  services.traefik.dynamicConfigOptions.http.middlewares.compression.compress = {};

  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard.rule = "Host(`traefik.${domain}`)";
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard.middlewares = [ "sso-internal@file" ];
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard.service = "api@internal";
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard.tls.certResolver = "letsencrypt";

  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.rule = "Host(`traefik.${domain}`) && ClientIP(`100.64.0.0/10`)";
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.middlewares = [ "local-ip-whitelist@file" "secure-headers@file" ];
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.service = "api@internal";
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.priority = 2000;
  services.traefik.dynamicConfigOptions.http.routers.traefik-dashboard-bypass.tls.certResolver = "letsencrypt";

  services.traefik.dynamicConfigOptions.tls.options.default.minVersion = "VersionTLS12";
  services.traefik.dynamicConfigOptions.tls.options.default.sniStrict = true;
  services.traefik.dynamicConfigOptions.tls.options.default.cipherSuites = [
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  ];
  services.traefik.dynamicConfigOptions.tls.options.default.curvePreferences = [ "CurveP384" "CurveP256" ];

  services.traefik.dynamicConfigOptions.tls.options.modern.minVersion = "VersionTLS13";
  services.traefik.dynamicConfigOptions.tls.options.modern.sniStrict = true;
  services.traefik.dynamicConfigOptions.tls.options.modern.cipherSuites = [
    "TLS_AES_256_GCM_SHA384"
    "TLS_AES_128_GCM_SHA256"
    "TLS_CHACHA20_POLY1305_SHA256"
  ];
  services.traefik.dynamicConfigOptions.tls.options.modern.curvePreferences = [ "CurveP521" "CurveP384" ];

  systemd.services.traefik = lib.mkIf (config.my.profiles.networking.reverseProxy == "traefik") {
    serviceConfig.Environment = [ "TZ=${config.time.timeZone}" ];
    serviceConfig.NoNewPrivileges = lib.mkForce true;
    serviceConfig.PrivateTmp = lib.mkForce true;
    serviceConfig.AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    serviceConfig.CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    serviceConfig.ProtectSystem = lib.mkForce "strict";
    serviceConfig.ReadWritePaths = [
      config.services.traefik.dataDir
      "/var/log/traefik"
    ];
    serviceConfig.ProtectHome = lib.mkForce true;
    serviceConfig.ProtectKernelTunables = lib.mkForce true;
    serviceConfig.ProtectKernelModules = lib.mkForce true;
    serviceConfig.ProtectControlGroups = lib.mkForce true;
    serviceConfig.RestrictRealtime = lib.mkForce true;
    serviceConfig.RestrictSUIDSGID = lib.mkForce true;
    serviceConfig.RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
}
