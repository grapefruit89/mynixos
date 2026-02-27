{ config, ... }:
{
  my.media = {
    # source-id: CFG.identity.domain
    defaults.domain = config.my.configs.identity.domain;

    # CONFINEMENT PREPARED (Set to "media-vault" once VPN handshake is fixed)
    sonarr.netns = null;
    radarr.netns = null;
    prowlarr.netns = null;
    readarr.netns = null;
    sabnzbd.netns = null;
    jellyseerr.netns = null;

    jellyfin.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    prowlarr.enable = true;
    sabnzbd.enable = true;
    jellyseerr.enable = true;
  };
}
