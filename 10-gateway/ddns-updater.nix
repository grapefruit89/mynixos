{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-006";
    title = "Ddns Updater";
    description = "Automated Dynamic DNS updates for Cloudflare and other providers.";
    layer = 10;
    nixpkgs.category = "services/networking";
    capabilities = [ "network/ddns" "cloudflare/integration" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  domain = config.my.configs.identity.domain;
  port = config.my.ports.ddnsUpdater;
in
{
  options.my.meta.ddns_updater = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for ddns-updater module";
  };


  config = lib.mkIf config.my.services.ddnsUpdater.enable {
    services.ddns-updater = {
      enable = true;
      environment = { LISTENING_ADDRESS = ":${toString port}"; PERIOD = "10m"; };
    };
    services.caddy.virtualHosts."nix-ddns.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };
  };
}
