/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-002
 *   title: "Caddy"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
  trustedIPs = "127.0.0.1 100.64.0.0/10 ${lib.concatStringsSep " " config.my.configs.network.lanCidrs}";
in
{
  # 🚀 CADDY EXHAUSTION
  services.caddy = {
    enable = config.my.profiles.networking.reverseProxy == "caddy";
    
    # Globales Hardening via Nix Option
    globalConfig = ''
      {
        # SRE Security Tuning
        servers {
          protocol {
            allow_h2c
          }
        }
        # Admin Interface nur lokal
        admin off
      }
    '';

    # Zentrale Konfiguration (Snippets & Bypasses)
    extraConfig = ''
      # 🛡️ Snippet für Security-Header
      (security_headers) {
        header {
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      }

      # 🔐 Snippet für SSO Auth (Pocket-ID) mit "Breaking Glass" Bypass
      (sso_auth) {
        @needs_auth {
          not remote_ip ${trustedIPs}
        }
        
        forward_auth @needs_auth localhost:${toString config.my.ports.pocketId} {
          uri /api/auth/verify
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
          header_up X-Forwarded-Uri {uri}
          header_up X-Forwarded-Method {method}
          copy_headers X-Forwarded-User
        }
        
        import security_headers
      }

      # --- LOKALER ZUGRIFF (mDNS + sslip.io Fallback + Notfall-IP + LAN-IP) ---
      nixhome.local, ${sslipHost}, rescue.local, 10.254.0.1, ${lanIP} {
        root * /var/www/landing-zone
        file_server
        import security_headers
      }
    '';
  };

  # systemd Hardening für Caddy
  systemd.services.caddy = {
    after = [ "adguardhome.service" "network-online.target" "sops-install-secrets.service" ];
    wants = [ "adguardhome.service" ];
    serviceConfig = {
      # SRE: Capability Hardening
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      # OOM Protection für den Edge-Proxy
      OOMScoreAdjust = -500;
    };
  };
}



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:fd3e5a209cc10b6b776c47a8fb36fdb083554c60dd38443b38708763954e3de1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
