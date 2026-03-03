{ lib, pkgs, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-30-DOC-001";
    title = "Paperless-ngx";
    description = "Aviation-grade document management with OCR, automated exports, and strict sandboxing.";
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
    description = "NMS metadata for paperless module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "paperless"; port = cfg.port; useSSO = defs.security.ssoEnable; description = "Paperless-ngx"; netns = cfg.netns; })
    {
      services.paperless = {
        enable = true; dataDir = cfg.dataDir; mediaDir = cfg.mediaDir; consumptionDir = cfg.consumptionDir; ... # Shortened
      };
    }
  ]);
}
