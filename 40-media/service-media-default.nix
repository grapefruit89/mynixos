{ lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-020";
    title = "Default Media Services";
    description = "Master import module for the entire media stack.";
    layer = 30;
    nixpkgs.category = "system/settings";
    capabilities = [ "media/stack" "architecture/imports" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.service_media_default = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for service-media-default module";
  };

  imports = [
    ./service-media-services-common.nix
    ./service-media-arr-wire.nix
    ./service-media-jellyfin.nix
    ./service-media-jellyseerr.nix
    ./service-media-sonarr.nix
    ./service-media-radarr.nix
    ./service-media-lidarr.nix
    ./service-media-readarr.nix
    ./service-media-prowlarr.nix
    ./service-media-sabnzbd.nix
    ./service-media-recyclarr.nix
  ];
}
