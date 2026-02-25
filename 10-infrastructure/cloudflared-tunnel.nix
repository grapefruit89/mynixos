{ config, lib, ... }:
let
  cfg = config.my.cloudflare.tunnel;
  creds = config.my.secrets.files.cloudflaredTunnelCredentials;
  traefikUrl = "https://127.0.0.1:${toString config.my.ports.traefikHttps}";
in
{
  options.my.cloudflare.tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel -> Traefik ingress bridge";

    tunnelId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Cloudflare tunnel UUID (as shown in Cloudflare Zero Trust).";
      example = "00000000-0000-0000-0000-000000000000";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      # source-id: CFG.identity.domain
      default = config.my.configs.identity.domain;
      description = "Base domain used by the tunnel ingress wildcard.";
    };

    wildcardPrefix = lib.mkOption {
      type = lib.types.str;
      default = "nix-*";
      description = "Subdomain wildcard routed through tunnel (default: nix-*).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tunnelId != "";
        message = "cloudflared: set my.cloudflare.tunnel.tunnelId to your tunnel UUID.";
      }
      {
        assertion = builtins.pathExists creds;
        message = "cloudflared: missing credentials file at ${creds}.";
      }
    ];

    # Traceability:
    # source: ${creds}
    # sink: services.cloudflared.tunnels.${cfg.tunnelId}
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = creds;

        # All nix-* hosts terminate at Traefik (HTTPS-only on localhost:443).
        ingress = {
          "${cfg.wildcardPrefix}.${cfg.domain}" = {
            service = traefikUrl;
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
