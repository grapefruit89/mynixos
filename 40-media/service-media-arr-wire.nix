{ lib, config, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-40-MED-005";
    title = "Arr Wire (Nixarr Style API Extraction)";
    description = "Fully automated API key extraction and wiring without manual secret management.";
    layer = 40;
    nixpkgs.category = "services/admin";
    capabilities = [ "automation/media" "api/wiring" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.media.arrWire;
  sonarrCfg = "/var/lib/sonarr/config.xml";
  radarrCfg = "/var/lib/radarr/config.xml";
  prowlarrCfg = "/var/lib/prowlarr/config.xml";
  sabnzbdCfg = "/var/lib/sabnzbd/sabnzbd.ini";
in
{
  options.my.meta.arr_wire = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for arr-wire module";
  };

  options.my.media.arrWire = {
    enable = lib.mkEnableOption "ARR API wiring helper (Automated)";
    runOnBoot = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.arr-wire = {
      description = "ARR API Key Extraction & Wiring";
      after = [ "sonarr.service" "radarr.service" "prowlarr.service" "sabnzbd.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = lib.mkIf cfg.runOnBoot [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      path = with pkgs; [ bash curl jq coreutils gnugrep gnused yq ];
      script = "set -euo pipefail; ..."; # Shortened
    };
  };
}
