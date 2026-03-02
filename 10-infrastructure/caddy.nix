/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-002
 *   title: "Caddy (SRE Ultra Edition)"
 *   layer: 10
 * summary: Tightly integrated edge proxy with Cloudflare Trust, Geoblocking (DE, AT, LT) and Zero-Downtime.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/caddy/default.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
  
  # sink: CFG.network.lanCidrs
  trustedIPs = "127.0.0.1 100.64.0.0/10 ${lib.concatStringsSep " " config.my.configs.network.lanCidrs}";
in
{
  # 🚀 KERNEL NETWORK TUNING (QUIC/HTTP3 Optimized)
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 8388608; # 8MB for high-performance QUIC/UDP
    "net.core.wmem_max" = 8388608;
    "net.ipv4.udp_rmem_min" = 16384;
    "net.ipv4.udp_wmem_min" = 16384;
    "net.ipv4.tcp_slow_start_after_idle" = 0; # Keep connections warm
  };

  services.caddy = {
    enable = config.my.profiles.networking.reverseProxy == "caddy";
    
    logFormat = lib.mkForce ''
      level INFO
      format json {
        time_format wall
      }
    '';

    globalConfig = ''
      admin localhost:2019
      
      # 🚀 Ultra-Performance Settings
      servers {
        trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
        
        # Enable HTTP/3 and QUIC performance
        protocols h1 h2 h3
      }
    '';

    extraConfig = ''
      (security_headers) {
        header {
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      }

      # 🌍 Snippet: Geoblock (SRE Standard)
      (geoblock) {
        @blocked {
          header Cf-Ipcountry *
          # Erlaubte Länder: DE (DE), AT (AT), Litauen (LT)
          not header Cf-Ipcountry DE
          not header Cf-Ipcountry AT
          not header Cf-Ipcountry LT
        }
        # SRE: Lokale IPs und Tailscale dürfen IMMER passieren
        @not_local {
          not remote_ip ${trustedIPs}
        }
        respond @blocked @not_local "Access denied from your country" 403
      }

      (sso_auth) {
        import geoblock
        @needs_auth {
          not remote_ip ${trustedIPs}
        }
        forward_auth @needs_auth localhost:${toString config.my.ports.pocketId} {
          uri /api/auth/verify
          copy_headers X-Forwarded-User
        }
        import security_headers
        encode zstd gzip # Performance: Kompression für alle SSO-geschützten Apps
      }

      nixhome.local, ${lanIP}, ${sslipHost}, rescue.local {
        log { output discard }
        tls internal
        handle {
          reverse_proxy localhost:${toString config.my.ports.olivetin}
        }
        import security_headers
        encode zstd gzip
      }
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
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
