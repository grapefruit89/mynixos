{ config, ... }:
{
  my.media = {
    # source-id: CFG.identity.domain
    defaults.domain = config.my.configs.identity.domain;

    jellyfin.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    prowlarr.enable = true;
    sabnzbd.enable = true;
    jellyseerr.enable = true;
  };
}
