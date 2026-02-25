{ ... }:
{
  # source: media module import list
  # sink:   activates shared media module stack
  imports = [
    ./services-common.nix
    ./arr-wire.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./sonarr.nix
    ./radarr.nix
    ./readarr.nix
    ./prowlarr.nix
    ./sabnzbd.nix
  ];
}
