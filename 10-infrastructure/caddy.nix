/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8aa113409cc6ad2e4601d9ceb0f6bcc1394ee408592c439948875c82a5d56aa5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
