/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-025
 *   title: "Media Stack"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:53373fbc9846eb902c87c9762e18c7f0887b408d86103cf6f3578c9929192f67
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
