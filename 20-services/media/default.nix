{ ... }:
{
  imports = [
    ./services-common.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./sonarr.nix
    ./radarr.nix
    ./readarr.nix
    ./prowlarr.nix
    ./sabnzbd.nix
  ];
}
