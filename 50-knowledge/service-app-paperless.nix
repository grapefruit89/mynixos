{ lib, pkgs, config, ... }:
let
  nms = {
    id = "NIXH-30-DOC-001";
    title = "Paperless-ngx";
    description = "Aviation-grade document management.";
    layer = 40;
    nixpkgs.category = "services/documents";
    capabilities = [ "document/management" "ocr/automated" "backup/exporter" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.documents.paperless;
  defs = config.my.defaults;
in
{
  options.my.meta.paperless = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  options.my.documents.paperless = {
    enable = lib.mkEnableOption "Paperless-ngx";
    dataDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/paperless"; };
    port = lib.mkOption { type = lib.types.port; default = 28981; };
    netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "paperless"; port = cfg.port; useSSO = true; description = "Paperless-ngx"; netns = cfg.netns; })
    {
      services.paperless = {
        enable = true;
        dataDir = cfg.dataDir;
      };
    }
  ]);
}
