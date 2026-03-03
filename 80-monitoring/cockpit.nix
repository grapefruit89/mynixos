{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-10-INF-005"; title = "Cockpit"; description = "Web admin."; layer = 10; nixpkgs.category = "tools/admin"; capabilities = [ "system/administration" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 1; };
  cfg = config.my.services.cockpit;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.cockpit;
in
{
  options.my.meta.cockpit = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  config = lib.mkIf cfg.enable {
    services.cockpit = { enable = true; port = port; package = pkgs.cockpit; settings = { WebService = { AllowUnencrypted = true; ProtocolHeader = "X-Forwarded-Proto"; }; Session = { IdleTimeout = 15; }; }; };
    services.caddy.virtualHosts."admin.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
  };
}
