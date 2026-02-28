/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Media Stack Enablement
 * TRACE-ID:     NIXH-SRV-016
 * PURPOSE:      Zentrale Aktivierung und Namespace-Zuordnung aller Media-Dienste.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ config, ... }:
{
  my.media = {
    defaults.domain = config.my.configs.identity.domain;
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
