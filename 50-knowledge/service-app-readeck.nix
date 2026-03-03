{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-013";
    title = "Readeck (SRE Hardened)";
    description = "Self-hosted 'read-it-later' service, tightly sandboxed with DynamicUser.";
    layer = 40;
    nixpkgs.category = "services/web-apps";
    capabilities = [ "web/read-it-later" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.readeck;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.readeck = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for readeck module";
  };


  config = lib.mkIf config.my.services.readeck.enable {
    services.readeck = { enable = true; settings = { server.host = "127.0.0.1"; server.port = port; log.level = "info"; }; environmentFile = config.sops.secrets.readeck_env.path; };
    services.caddy.virtualHosts."read.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.readeck.serviceConfig = { DynamicUser = true; ProtectSystem = "full"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; SystemCallFilter = [ "@system-service" "~@privileged" ]; OOMScoreAdjust = 300; };
  };
}
