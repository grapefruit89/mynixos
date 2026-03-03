{ config, pkgs, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-010";
    title = "Landing Zone Ui";
    description = "Static landing page for authenticated local/VPN access bypassing SSO.";
    layer = 10;
    nixpkgs.category = "web/apps";
    capabilities = [ "web/landing-page" "security/rescue-access" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  rescueHtml = pkgs.writeTextDir "index.html" "<html>...</html>"; # Shortened for brevity in this step
in
{
  options.my.meta.landing_zone_ui = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for landing-zone-ui module";
  };


  config = lib.mkIf config.my.services.landingZone.enable {
    systemd.tmpfiles.rules = [ "d /var/www/landing-zone 0755 caddy caddy -" "L+ /var/www/landing-zone/index.html - - - - ${rescueHtml}/index.html" ];
  };
}
