/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-002
 *   title: "Caddy (SRE Optimization)"
 *   layer: 10
 * summary: High-performance edge proxy with UDP/QUIC tuning and Journald logging.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/caddy/default.nix
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
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
  };

  services.caddy = {
    enable = config.my.profiles.networking.reverseProxy == "caddy";
    
    # ── LOG ZENTRALISIERUNG ────────────────────────────────────────────────
    # Wir biegen die Caddy-Logs so um, dass sie NICHT in eine Datei schreiben,
    # sondern direkt als JSON ins Systemd-Journal fließen.
    logFormat = lib.mkForce ''
      level INFO
      format json
    '';

    globalConfig = ''
      admin localhost:2019
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

      # Standard-Handler für alle vHosts: Logging ins Journal aktivieren
      # Nutze 'log' Direktive in jedem vHost für detaillierte Access-Logs
      
      nixhome.local, ${lanIP}, ${sslipHost}, rescue.local, 10.254.0.1 {
        log {
          output discard # Standard-Output wegwerfen, da globalConfig ins Journal schreibt
        }
        tls internal
        handle_path /certs/* {
          root * /data/state/mtls
          file_server browse
        }
        handle {
          reverse_proxy localhost:${toString config.my.ports.olivetin}
        }
        import security_headers
      }
    '';
  };

  systemd.services.caddy = {
    after = [ "adguardhome.service" "network-online.target" "sops-install-secrets.service" ];
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
