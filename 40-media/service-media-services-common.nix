{ lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-031";
    title = "Services Common";
    description = "Common media service defaults and global configuration attributes.";
    layer = 30;
    nixpkgs.category = "system/settings";
    capabilities = [ "media/defaults" "architecture/common" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.service_media_services_common = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for service-media-services-common module";
  };

  options.my.media.defaults = {
    domain = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    hostPrefix = lib.mkOption { type = lib.types.str; default = "nix"; };
    netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
  };

  config.assertions = [ { assertion = config.my.media.defaults.domain != null; message = "my.media.defaults.domain must be set."; } ];
}
