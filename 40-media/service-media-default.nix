{ lib, ... }:
let
  nms = {
    id = "NIXH-40-MED-006";
    title = "Default Media Services";
    description = "Master import module for the entire media stack.";
    layer = 40;
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
    description = "NMS metadata";
  };

  imports = [
    # Wir importieren hier nur echte Module. 
    # Helper (_lib, _factory) werden von den Modulen selbst importiert.
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
