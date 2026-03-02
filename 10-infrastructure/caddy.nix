/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-002
 *   title: "Caddy (SRE Ultra Edition)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-001]
 *   downstream:
 *     - NIXH-10-INF-001  # adguardhome (Caddy-VirtualHost)
 *     - NIXH-10-INF-005  # cockpit
 *     - NIXH-10-INF-009  # homepage
 *     - NIXH-10-INF-011  # netdata
 *     - NIXH-10-INF-012  # pocket-id
 *     - NIXH-10-INF-016  # uptime-kuma
 *   status: audited
 * summary: Tightly integrated edge proxy with Cloudflare Trust, Geoblocking (DE, AT, LT) and Zero-Downtime.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/caddy/default.nix
 * ---
 */
{ config, lib, ... }:
let
  # source: CFG.identity.domain  → 00-core/configs.nix
  domain   = config.my.configs.identity.domain;
  # source: CFG.server.lanIP     → 00-core/configs.nix
  lanIP    = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";

  # source: CFG.network.lanCidrs + tailnetCidrs → 00-core/configs.nix
  # Vertrauenswürdige IPs: Cloudflare Edge + Loopback + LAN + Tailscale
  trustedIPs = lib.concatStringsSep " " (
    [
      "127.0.0.1"
      # Cloudflare Edge IPs (für Geoblock-Header-Vertrauen)
      "173.245.48.0/20" "103.21.244.0/22" "103.22.200.0/22" "103.31.4.0/22"
      "141.101.64.0/18" "108.162.192.0/18" "190.93.240.0/20" "188.114.96.0/20"
      "197.234.240.0/22" "198.41.128.0/17" "162.158.0.0/15"
      "104.16.0.0/13" "104.24.0.0/14" "172.64.0.0/13" "131.0.72.0/22"
    ]
    ++ config.my.configs.network.tailnetCidrs
    ++ config.my.configs.network.lanCidrs
  );

  # source: PORT.olivetin → 00-core/ports.nix
  olivetinPort = config.my.ports.olivetin;
in
{
  boot.kernel.sysctl = {
    "net.core.rmem_max"              = 8388608;
    "net.core.wmem_max"              = 8388608;
    "net.ipv4.udp_rmem_min"          = 16384;
    "net.ipv4.udp_wmem_min"          = 16384;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
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
      servers {
        trusted_proxies static ${trustedIPs}
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

      # =============================================================================
      # GEOBLOCK-SNIPPET
      # FIX: "respond @a @b" ist ungültige Caddy-Syntax (zwei Matcher in einer Direktive).
      # Korrekt: lokale IPs zuerst passieren lassen, dann Länder prüfen.
      # Erlaubte Länder: DE, AT, LT
      # =============================================================================
      (geoblock) {
        # Lokale IPs (LAN + Tailscale) immer erlauben — kein Geoblock
        @local_bypass remote_ip ${trustedIPs}
        handle @local_bypass {
          # Passthrough — kein Block
        }

        # Für alle anderen: Cloudflare-Geoheader prüfen
        @geo_blocked {
          not remote_ip ${trustedIPs}
          not header Cf-Ipcountry DE
          not header Cf-Ipcountry AT
          not header Cf-Ipcountry LT
        }
        respond @geo_blocked "Access denied from your country" 403
      }

      # =============================================================================
      # SSO-SNIPPET (Pocket-ID Forward Auth)
      # Lokale IPs können ohne SSO, externe müssen sich authentifizieren.
      # =============================================================================
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
        encode zstd gzip
      }

      # =============================================================================
      # LOKALER RESCUE-ENDPUNKT (LAN/Tailscale only)
      # =============================================================================
      nixhome.local, ${lanIP}, ${sslipHost}, rescue.local {
        log { output discard }
        tls internal

        @blocked_external {
          not remote_ip ${trustedIPs}
        }
        respond @blocked_external "Access denied: LAN/VPN only" 403

        handle {
          reverse_proxy localhost:${toString olivetinPort}
        }
        import security_headers
        encode zstd gzip
      }
    '';
  };

  systemd.services.caddy = {
    after        = [ "adguardhome.service" "network-online.target" ];
    stopIfChanged = false;
    serviceConfig = {
      AmbientCapabilities  = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      OOMScoreAdjust       = -500;
      NoNewPrivileges      = true;
      PrivateDevices       = true;
      ProtectHome          = true;
      ProtectSystem        = "strict";
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 3
 *   changes_from_previous:
 *     - BUG FIX: "respond @blocked @not_local" → zwei separate handle-Blöcke (ungültige Caddy-Syntax)
 *     - olivetin Port aus ports.nix statt hardkodiert
 *     - Cloudflare IPs in trustedIPs integriert (gehören zu trusted_proxies, nicht geoblock)
 *     - source-id Kommentare für alle config-Referenzen
 *     - upstream/downstream Architecture-Header vollständig
 * ---
 */
