{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  # Erzeugt eine sslip.io Adresse (z.B. 192-168-2-73.sslip.io)
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";
in
{
  services.caddy = {
    enable = true;
    
    extraConfig = ''
      # Snippet für SSO Auth (Pocket-ID)
      (sso_auth) {
        forward_auth localhost:${toString config.my.ports.pocketId} {
          uri /api/auth/verify
          header_up X-Forwarded-Proto {scheme}
          header_up X-Forwarded-Host {host}
        }
      }

      # --- LOKALER ZUGRIFF (mDNS + sslip.io Fallback) ---
      # Erreichbar unter nixhome.local UND der IP-basierten sslip-Domain
      nixhome.local, ${sslipHost} {
        # Lokaler Zugriff braucht kein SSL (oder self-signed)
        reverse_proxy localhost:8082
      }
    '';
  };
}
