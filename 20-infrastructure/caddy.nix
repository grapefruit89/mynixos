/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Caddy
 * TRACE-ID:     NIXH-INF-001
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:748affeaa125a078b94ebb1ddb38336b4bf6101ec342ede2f1a0fea90b38e6ac
 */

{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
  trustedIPs = "127.0.0.1 100.64.0.0/10 ${lib.concatStringsSep " " config.my.configs.network.lanCidrs}";
in
{
  systemd.services.caddy.after = [ 
    "adguardhome.service"
    "network-online.target"
    "sops-install-secrets.service"
  ];
  systemd.services.caddy.wants = [ "adguardhome.service" ];

  services.caddy.enable = config.my.profiles.networking.reverseProxy == "caddy";
  services.caddy.extraConfig = ''
    # Snippet für SSO Auth (Pocket-ID) mit "Breaking Glass" Bypass
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
    }

    # --- LOKALER ZUGRIFF (mDNS + sslip.io Fallback + Notfall-IP + LAN-IP) ---
    nixhome.local, ${sslipHost}, rescue.local, 10.254.0.1, ${lanIP} {
      root * /var/www/landing-zone
      file_server
    }
  '';
}
