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
      default = "*.nix";
      description = "Subdomain wildcard routed through tunnel (default: *.nix).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tunnelId != "";
        message = "cloudflared: set my.cloudflare.tunnel.tunnelId to your tunnel UUID.";
      }
      # builtins.pathExists creds ENTFERNT (Laufzeit-Check)
    ];

    # Laufzeit-Check statt Build-Zeit-Assertion
    systemd.services."cloudflared-tunnel-${cfg.tunnelId}".preStart = ''
      if [ ! -f "${creds}" ]; then
        echo "FEHLER: Cloudflared-Credentials fehlen unter ${creds}"
        echo "Lösung: sops -d /etc/nixos/secrets.yaml | jq -r '.[\"cloudflared_creds\"]' > ${creds}"
        exit 1
      fi
    '';

    # Traceability:
    # source: ${creds}
    # sink: services.cloudflared.tunnels.${cfg.tunnelId}
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = creds;

        # All nix-* hosts terminate at Proxy (HTTPS-only on localhost:443).
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
