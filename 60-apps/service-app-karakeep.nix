{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-APP-015";
    title = "Karakeep (SRE Hardened)";
    description = "Bookmark management tool with SRE sandboxing.";
    layer = 20;
    nixpkgs.category = "web/apps";
    capabilities = [ "web/bookmarks" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  port = config.my.ports.karakeep;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.karakeep = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for karakeep module";
  };


  config = lib.mkIf config.my.services.karakeep.enable {
    services.karakeep = { enable = true; extraEnvironment = { PORT = toString port; DISABLE_SIGNUPS = "true"; }; };
    services.caddy.virtualHosts."bookmarks.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
  };
}
