/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Caddy Edge Proxy
 * TRACE-ID:     NIXH-INF-002
 * PURPOSE:      Moderner Reverse-Proxy mit automatischem HTTPS und "Breaking Glass" Bypass.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
in
{
  systemd.services.caddy = {
    after = [ 
      "adguardhome.service"
      "network-online.target"
      "sops-install-secrets.service"
    ];
    wants = [ "adguardhome.service" ];
  };

  services.caddy = {
    enable = config.my.profiles.networking.reverseProxy == "caddy";
    
    extraConfig = ''
      # Snippet für SSO Auth (Pocket-ID)
      (sso_auth) {
        # BREAK-GLASS: Tailscale IPs (100.64.0.0/10) dürfen ohne SSO rein
        @tailscale remote_ip 100.64.0.0/10
        handle @tailscale {
          header +X-Nix-Auth-Bypass "Tailscale-Rescue"
        }

        handle {
          forward_auth localhost:${toString config.my.ports.pocketId} {
            uri /api/auth/verify
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Host {host}
            header_up X-Forwarded-Uri {uri}
            header_up X-Forwarded-Method {method}
          }
        }
      }

      # --- LOKALER ZUGRIFF (mDNS + sslip.io Fallback + Notfall-IP + LAN-IP) ---
      nixhome.local, ${sslipHost}, rescue.local, 10.254.0.1, ${lanIP} {
        root * /var/www/landing-zone
        file_server
      }
    '';
  };
}
