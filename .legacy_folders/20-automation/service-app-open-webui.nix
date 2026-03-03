{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-011";
    title = "Open WebUI (SRE Hardened)";
    description = "User-friendly WebUI for LLMs, tightly sandboxed with DynamicUser.";
    layer = 20;
    nixpkgs.category = "services/misc";
    capabilities = [ "ai/ui" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.openWebui;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.open_webui = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for open-webui module";
  };


  config = lib.mkIf config.my.services.openWebui.enable {
    services.open-webui = {
      enable = true; host = "127.0.0.1"; port = port;
      environment = { OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.my.ports.ollama}"; SCARF_NO_ANALYTICS = "True"; DO_NOT_TRACK = "True"; ANONYMIZED_TELEMETRY = "False"; };
    };
    services.caddy.virtualHosts."ai.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.open-webui.serviceConfig = { DynamicUser = true; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; SupplementaryGroups = [ "render" "video" ]; SystemCallFilter = [ "@system-service" "~@privileged" ]; OOMScoreAdjust = 200; };
  };
}
