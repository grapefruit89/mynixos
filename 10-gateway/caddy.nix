{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten (Aviation-Grade)
  nms = {
    id = "NIXH-10-GTW-002";
    title = "Caddy (M1 Abrams Edition)";
    description = "Tightly integrated edge proxy with Cloudflare DNS-01, Jellyfin Smart-Auth and mTLS.";
    layer = 10;
    nixpkgs.category = "servers/proxy";
    capabilities = ["network/reverse-proxy" "security/waf" "security/mtls" "automation/dns-01"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };

  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  sslipHost = "${lib.replaceStrings ["."] ["-"] lanIP}.sslip.io";

  trustedIPs = lib.concatStringsSep " " (
    ["127.0.0.1" "173.245.48.0/20" "103.21.244.0/22" "103.22.200.0/22" "103.31.4.0/22" "141.101.64.0/18" "108.162.192.0/18" "190.93.240.0/20" "188.114.96.0/20" "197.234.240.0/22" "198.41.128.0/17" "162.158.0.0/15" "104.16.0.0/13" "104.24.0.0/14" "172.64.0.0/13" "131.0.72.0/22"]
    ++ config.my.configs.network.tailnetCidrs
    ++ config.my.configs.network.lanCidrs
  );
  olivetinPort = config.my.ports.olivetin;
in {
  # 🧬 Audit-Compliance: Metadaten als echtes Nix-Attribut
  options.my.meta.caddy = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  config = lib.mkIf config.my.services.caddy.enable {
    # 🏎️ KERNEL TUNING
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 8388608;
      "net.core.wmem_max" = 8388608;
      "net.ipv4.tcp_fastopen" = 3;
    };

    services.caddy = {
      enable = true;
      globalConfig = ''
        admin localhost:2019
        servers {
          trusted_proxies static ${trustedIPs}
        }
      '';

      extraConfig = ''
        # --- M1 ABRAMS SNIPPETS ---
        (security_headers) {
          header {
            X-Content-Type-Options nosniff
            X-Frame-Options DENY
            Referrer-Policy no-referrer-when-downgrade
            Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          }
        }

        # 🛡️ mTLS: Mutual TLS für passwortlose Authentifizierung
        (mtls_auth) {
          tls {
            client_auth {
              mode require_and_verify
              trust_pool file /etc/nixos/secrets/mtls/ca.crt
            }
          }
          import security_headers
        }

        # 🔑 Pocket-ID SSO Integration
        (sso_auth) {
          @needs_auth {
            not remote_ip ${trustedIPs}
          }
          forward_auth @needs_auth localhost:${toString config.my.ports.pocketId} {
            uri /api/auth/verify
            copy_headers X-Forwarded-User
          }
          import security_headers
        }

        # --- WILDCARD DNS ---
        *.nix.m7c5.de {
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          }

          # Zertifikat-Download (für OliveTin mTLS Generator)
          handle /certs/* {
            root * /var/www/landing-zone
            file_server browse
          }
        }
      '';
    };

    # 🛡️ SYSTEMD SANDBOXING (Aviation Grade)
    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = [config.sops.templates."caddy-env".path];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      MemoryDenyWriteExecute = true;
      OOMScoreAdjust = -500;
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04e2fdddc
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

