{ ... }:
{
  imports = [
    ./services-common.nix
    ./jellyfin.nix
    ./sonarr.nix
    ./radarr.nix
    ./prowlarr.nix
    ./sabnzbd.nix
  ];
}
