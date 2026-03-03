{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-012";
    title = "Pocket-ID (SRE Exhausted)";
    description = "OIDC identity provider with automated bootstrap and aviation-grade hardening.";
    layer = 10;
    nixpkgs.category = "services/security";
    capabilities = [ "security/oidc" "identity/provider" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  subdomain = config.my.configs.identity.subdomain;
  port = config.my.ports.pocketId;
in
{
  options.my.meta.pocket_id = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for pocket-id module";
  };

  config = lib.mkIf cfg.enable {
    warnings = [ "pocket-id: public_registration = true ist aktiv! Nach Ersteinrichtung auf false setzen." ];
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = { issuer = lib.mkForce "https://auth.${subdomain}.${domain}"; title = "m7c5 Login"; public_registration = true; };
    };
    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true;
      LockPersonality = true; ProtectControlGroups = true; ProtectKernelModules = true; ProtectKernelTunables = true;
      RestrictRealtime = true; RestrictSUIDSGID = true; Restart = "always"; RestartSec = "5s"; OOMScoreAdjust = -100;
    };
    services.caddy.virtualHosts."auth.${subdomain}.${domain}" = {
      extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
    };
  };
}
