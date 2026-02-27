{ config, ... }:
{
  my.media = {
    # source-id: CFG.identity.domain
    defaults.domain = config.my.configs.identity.domain;

    # FULL-STACK CONFINEMENT (Phase 3, Step 2)
    # All services below are physically isolated in 'media-vault'
    defaults.netns = "media-vault";

    jellyfin.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    prowlarr.enable = true;
    sabnzbd.enable = true;
    jellyseerr.enable = true;
  };
}
