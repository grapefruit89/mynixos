{ config, pkgs, lib, ... }:
let
  nms = { id = "NIXH-10-GTW-008"; title = "Landing Zone Ui"; description = "Static landing page."; layer = 10; nixpkgs.category = "web/apps"; capabilities = [ "web/landing-page" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 1; };
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  rescueHtml = pkgs.writeTextDir "index.html" "<html><body>Rettungsweg</body></html>";
in
{
  options.my.meta.landing_zone_ui = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  config = lib.mkIf (config.my.services.landingZone.enable or true) {
    systemd.tmpfiles.rules = [ "d /var/www/landing-zone 0755 caddy caddy -" "L+ /var/www/landing-zone/index.html - - - - ${rescueHtml}/index.html" ];
  };
}
