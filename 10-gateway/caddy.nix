{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-002";
    title = "Caddy (SRE Ultra Edition)";
    description = "Tightly integrated edge proxy with Cloudflare Trust, Geoblocking (DE, AT, LT) and Zero-Downtime.";
    layer = 10;
    nixpkgs.category = "servers/proxy";
    capabilities = [ "network/reverse-proxy" "security/geoblock" "security/sso-integration" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
  trustedIPs = lib.concatStringsSep " " (
    [ "127.0.0.1" "173.245.48.0/20" "103.21.244.0/22" "103.22.200.0/22" "103.31.4.0/22" "141.101.64.0/18" "108.162.192.0/18" "190.93.240.0/20" "188.114.96.0/20" "197.234.240.0/22" "198.41.128.0/17" "162.158.0.0/15" "104.16.0.0/13" "104.24.0.0/14" "172.64.0.0/13" "131.0.72.0/22" ]
    ++ config.my.configs.network.tailnetCidrs
    ++ config.my.configs.network.lanCidrs
  );
  olivetinPort = config.my.ports.olivetin;
in
{
  options.my.meta.caddy = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for caddy module";
  };

  config = {
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 8388608; "net.core.wmem_max" = 8388608;
      "net.ipv4.udp_rmem_min" = 16384; "net.ipv4.udp_wmem_min" = 16384;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
    };

    services.caddy = {
      enable = config.my.profiles.networking.reverseProxy == "caddy";
      logFormat = lib.mkForce "level INFO\nformat json { time_format wall }";
      globalConfig = "admin localhost:2019\nservers { trusted_proxies static ${trustedIPs}\nprotocols h1 h2 h3 }";
      extraConfig = ''
        (security_headers) { header { X-Content-Type-Options nosniff\nX-Frame-Options DENY\nReferrer-Policy no-referrer-when-downgrade\nStrict-Transport-Security "max-age=31536000; includeSubDomains; preload" } }
        (geoblock) { @local_bypass remote_ip ${trustedIPs}\nhandle @local_bypass { } @geo_blocked { not remote_ip ${trustedIPs}\nnot header Cf-Ipcountry DE\nnot header Cf-Ipcountry AT\nnot header Cf-Ipcountry LT } respond @geo_blocked "Access denied" 403 }
        (sso_auth) { import geoblock\n@needs_auth { not remote_ip ${trustedIPs} } forward_auth @needs_auth localhost:${toString config.my.ports.pocketId} { uri /api/auth/verify\ncopy_headers X-Forwarded-User } import security_headers\nenforce zstd gzip }
        nixhome.local, ${lanIP}, ${sslipHost}, rescue.local { log { output discard } tls internal\n@blocked_external { not remote_ip ${trustedIPs} } respond @blocked_external "Access denied" 403\nhandle { reverse_proxy localhost:${toString olivetinPort} } import security_headers\nenforce zstd gzip }
      '';
    };

    systemd.services.caddy = {
      after = [ "adguardhome.service" "network-online.target" ];
      stopIfChanged = false;
      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        OOMScoreAdjust = -500;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
      };
    };
  };
}
