{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-GTW-003";
    title = "Cloudflared Tunnel (SRE Exhausted)";
    description = "Secure Ingress bridge using Cloudflare Tunnels for zero-port-forwarding connectivity.";
    layer = 10;
    nixpkgs.category = "services/networking";
    capabilities = [ "network/ingress" "security/tunnel" "cloudflare/integration" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.cloudflare.tunnel;
  creds = config.my.secrets.files.cloudflaredTunnelCredentials;
  proxyUrl = if config.my.profiles.networking.reverseProxy == "caddy"
             then "https://127.0.0.1:443"
             else "https://127.0.0.1:${toString config.my.ports.edgeHttps}";
in
{
  options.my.meta.cloudflared_tunnel = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for cloudflared-tunnel module";
  };

  options.my.cloudflare.tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel → Ingress bridge";
    tunnelId = lib.mkOption { type = lib.types.str; default = ""; };
    domain = lib.mkOption { type = lib.types.str; default = config.my.configs.identity.domain; };
    wildcardPrefix = lib.mkOption { type = lib.types.str; default = "*.nix"; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ { assertion = cfg.tunnelId != ""; message = "cloudflared: tunnelId muss gesetzt sein."; } ];
    systemd.services."cloudflared-tunnel-${cfg.tunnelId}" = {
      preStart = "if [ ! -f '${creds}' ]; then echo 'FEHLER: Credentials fehlen.'; exit 1; fi";
      serviceConfig = {
        ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true;
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ]; AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        OOMScoreAdjust = -500;
      };
    };
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = creds;
        ingress = {
          "${cfg.wildcardPrefix}.${cfg.domain}" = {
            service = proxyUrl;
            originRequest = { noTLSVerify = false; originServerName = "${cfg.wildcardPrefix}.${cfg.domain}"; http2Origin = true; keepAliveConnections = 8; };
          };
        };
        default = "http_status:404";
      };
    };
  };
}
