/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Cloudflare Tunnel Ingress
 * TRACE-ID:     NIXH-INF-006
 * PURPOSE:      Bridge zwischen Cloudflare Zero Trust Tunnel und lokalem Proxy.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/secrets.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, lib, ... }:
let
  cfg = config.my.cloudflare.tunnel;
  creds = config.my.secrets.files.cloudflaredTunnelCredentials;
  proxyUrl = if config.my.profiles.networking.reverseProxy == "caddy"
             then "https://127.0.0.1:443"
             else "https://127.0.0.1:${toString config.my.ports.traefikHttps}";
in
{
  options.my.cloudflare.tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel -> Ingress bridge";

    tunnelId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Cloudflare tunnel UUID.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.my.configs.identity.domain;
      description = "Base domain used by the tunnel ingress wildcard.";
    };

    wildcardPrefix = lib.mkOption {
      type = lib.types.str;
      default = "*.nix";
      description = "Subdomain wildcard routed through tunnel.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tunnelId != "";
        message = "cloudflared: set my.cloudflare.tunnel.tunnelId to your tunnel UUID.";
      }
    ];

    systemd.services."cloudflared-tunnel-${cfg.tunnelId}".preStart = ''
      if [ ! -f "${creds}" ]; then
        echo "FEHLER: Cloudflared-Credentials fehlen unter ${creds}"
        echo "Lösung: sops -d /etc/nixos/secrets.yaml | jq -r '.[\"cloudflared_creds\"]' > ${creds}"
        exit 1
      fi
    '';

    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = creds;
        ingress = {
          "${cfg.wildcardPrefix}.${cfg.domain}" = {
            service = proxyUrl;
            originRequest = {
              noTLSVerify = true;
              originServerName = "${cfg.wildcardPrefix}.${cfg.domain}";
            };
          };
        };
        default = "http_status:404";
      };
    };
  };
}
