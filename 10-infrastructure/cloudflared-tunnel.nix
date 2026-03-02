/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-004
 *   title: "Cloudflared Tunnel (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-022, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  cfg   = config.my.cloudflare.tunnel;
  creds = config.my.secrets.files.cloudflaredTunnelCredentials;
  proxyUrl = if config.my.profiles.networking.reverseProxy == "caddy"
             then "https://127.0.0.1:443"
             else "https://127.0.0.1:${toString config.my.ports.edgeHttps}";
in
{
  options.my.cloudflare.tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel → Ingress bridge";

    tunnelId = lib.mkOption {
      type        = lib.types.str;
      default     = "";
      description = "Cloudflare Tunnel UUID (aus 'cloudflared tunnel list').";
    };

    domain = lib.mkOption {
      type        = lib.types.str;
      default     = config.my.configs.identity.domain;
      description = "Basis-Domain für den Tunnel-Ingress Wildcard.";
    };

    wildcardPrefix = lib.mkOption {
      type        = lib.types.str;
      default     = "*.nix";
      description = "Subdomain-Wildcard die durch den Tunnel geroutet wird.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tunnelId != "";
        message   = "cloudflared: my.cloudflare.tunnel.tunnelId muss gesetzt sein (Tunnel UUID).";
      }
    ];

    systemd.services."cloudflared-tunnel-${cfg.tunnelId}" = {
      preStart = ''
        if [ ! -f "${creds}" ]; then
          echo "FEHLER: Cloudflared-Credentials fehlen unter ${creds}"
          echo "Lösung: nixos-rebuild switch (sops-nix entschlüsselt automatisch)"
          exit 1
        fi
      '';

      serviceConfig = {
        ProtectSystem         = "strict";
        ProtectHome           = true;
        PrivateTmp            = true;
        PrivateDevices        = true;
        NoNewPrivileges       = true;
        # cloudflared braucht UDP für QUIC/HTTP3
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        AmbientCapabilities   = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        ProtectControlGroups  = true;
        ProtectKernelModules  = true;
        ProtectKernelTunables = true;
        RestrictRealtime      = true;
        RestrictSUIDSGID      = true;
        OOMScoreAdjust        = -500; # Edge-Anbindung ist kritisch
      };
    };

    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = creds;
        ingress = {
          "${cfg.wildcardPrefix}.${cfg.domain}" = {
            service = proxyUrl;
            originRequest = {
              # FIX: noTLSVerify = true war ein Security-Problem.
              # Caddy hat ein gültiges sslip.io-Zertifikat → TLS-Verifikation aktivieren.
              # Falls lokales self-signed: caPool auf Caddy-CA zeigen.
              noTLSVerify        = false;
              originServerName   = "${cfg.wildcardPrefix}.${cfg.domain}";
              http2Origin        = true;
              # FIX: 128 Connections für Homelab überdimensioniert → 8 reichen
              keepAliveConnections = 8;
              keepAliveTimeout   = "90s";
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
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - SECURITY FIX: noTLSVerify = true → false (Caddy hat gültiges Zertifikat)
 *     - keepAliveConnections 128 → 8 (Homelab-angemessen)
 *     - preStart Fehlermeldung verbessert (sops-nix Hinweis)
 *     - Architecture-Header ergänzt
 * ---
 */
