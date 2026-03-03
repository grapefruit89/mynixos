{ ... }:
{
  imports = [
    ./media-stack.nix
    ./service-app-audiobookshelf.nix
    ./service-media-arr-wire.nix
    ./service-media-default.nix
    ./service-media-jellyfin.nix
    ./service-media-jellyseerr.nix
    ./service-media-lidarr.nix
    ./service-media-media-stack.nix
    ./service-media-prowlarr.nix
    ./service-media-radarr.nix
    ./service-media-readarr.nix
    ./service-media-recyclarr.nix
    ./service-media-sabnzbd.nix
    ./service-media-services-common.nix
    ./service-media-sonarr.nix
  ];
}
