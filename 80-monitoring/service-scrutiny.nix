{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-80-MON-003";
    title = "Scrutiny (SRE Hardened)";
    description = "Hard drive S.M.A.R.T monitoring with automated collection and InfluxDB trends.";
    layer = 80;
    nixpkgs.category = "services/monitoring";
    capabilities = [ "monitoring/smart" "hardware/health" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.scrutiny;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.scrutiny = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for scrutiny module";
  };


  config = lib.mkIf config.my.services.scrutiny.enable {
    services.scrutiny = { enable = true; settings = { web.listen.port = port; web.listen.host = "127.0.0.1"; log.level = "INFO"; }; influxdb.enable = true; collector = { enable = true; schedule = "daily"; }; };
    services.caddy.virtualHosts."scrutiny.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.scrutiny.serviceConfig = { DynamicUser = true; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; OOMScoreAdjust = 800; };
    services.smartd.enable = true;
  };
}
