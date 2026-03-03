{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-038";
    title = "User Preferences";
    description = "Customized user preferences and personal system adjustments.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["user/preferences"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in {
  options.my.meta.user_preferences = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for user-preferences module";
  };

  config = {
    # Platz für persönliche Anpassungen.
  };
}
