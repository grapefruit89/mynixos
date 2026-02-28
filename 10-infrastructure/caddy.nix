{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  # Erzeugt eine sslip.io Adresse (z.B. 192-168-2-73.sslip.io)
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
      # Erreichbar unter nixhome.local UND der IP-basierten sslip-Domain UND der Notfall-IP UND der LAN-IP direkt
      nixhome.local, ${sslipHost}, rescue.local, 10.254.0.1, ${lanIP} {
        # Lokaler Zugriff zeigt die Landing-Zone UI als zentralen Einstieg
        root * /var/www/landing-zone
        file_server
      }
    '';
  };
}
