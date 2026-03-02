/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-002
 *   title: "Caddy (SRE Ultra Edition)"
 *   layer: 10
 * summary: Tightly integrated edge proxy with Cloudflare Trust, Geoblocking and Zero-Downtime.
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
  # ── KERNEL OPTIMIERUNG (HTTP/3) ──────────────────────────────────────────
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
  };

  services.caddy = {
    enable = config.my.profiles.networking.reverseProxy == "caddy";
    
    # ── LOGGING (RAM-Journal Optimized) ───────────────────────────────────
    logFormat = lib.mkForce ''
      level INFO
      format json {
        time_format wall
      }
    '';

    globalConfig = ''
      # Admin Interface nur lokal
      admin localhost:2019

      # ── CLOUDFARE TRUSTED PROXIES ─────────────────────────────────────────
      # SRE: Damit Caddy die echte Client-IP sieht und nicht die von Cloudflare.
      # (Benötigt für Geoblock und Fail2ban)
      servers {
        trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
      }
    '';

    extraConfig = ''
      # 🛡️ Snippet: Security-Header (Infosec 2026)
      (security_headers) {
        header {
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      }

      # 🌍 Snippet: Geoblock (Cloudflare Assisted)
      # Blockiert alle Anfragen, die nicht aus DE kommen.
      (geoblock) {
        @not_de {
          header Cf-Ipcountry *
          not header Cf-Ipcountry DE
        }
        # SRE: Ausnahme für lokale Netze
        @not_local {
          not remote_ip ${trustedIPs}
        }
        respond @not_de @not_local "Access denied from your country" 403
      }

      # 🔐 Snippet: SSO Auth (Pocket-ID)
      (sso_auth) {
        # Geoblock zuerst prüfen
        import geoblock

        @needs_auth {
          not remote_ip ${trustedIPs}
        }
        
        forward_auth @needs_auth localhost:${toString config.my.ports.pocketId} {
          uri /api/auth/verify
          copy_headers X-Forwarded-User
        }
        
        import security_headers
      }

      # --- LOKALER ZUGRIFF ---
      nixhome.local, ${lanIP}, ${sslipHost}, rescue.local {
        log { output discard }
        tls internal
        handle {
          reverse_proxy localhost:${toString config.my.ports.olivetin}
        }
        import security_headers
      }
    '';
  };

  # ── SYSTEMD HARDENING ──────────────────────────────────────────────────
  systemd.services.caddy = {
    after = [ "adguardhome.service" "network-online.target" ];
    stopIfChanged = false; # Zero-Downtime
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
