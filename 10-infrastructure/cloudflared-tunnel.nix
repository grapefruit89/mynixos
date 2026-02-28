/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-004
 *   title: "Cloudflared Tunnel"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  cfg = config.my.cloudflare.tunnel;
  creds = config.my.secrets.files.cloudflaredTunnelCredentials;
  proxyUrl = if config.my.profiles.networking.reverseProxy == "caddy"
             then "https://127.0.0.1:443"
             else "https://127.0.0.1:${toString config.my.ports.edgeHttps}";
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








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:c7d77661aa94f83a8337ced4d6bc7727cff3dc2e015ba88bc986d063eaa1c0e7
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
