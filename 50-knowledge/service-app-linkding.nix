{ lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-50-KNW-001";
    title = "Linkding";
    description = "Bookmark manager (Placeholder - Not yet implemented).";
    layer = 50;
    nixpkgs.category = "web/apps";
    capabilities = [ "web/bookmarks" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.linkding = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for linkding module";
  };


  config = lib.mkIf config.my.services.linkding.enable {
    # Implementierung folgt.
  };
}
