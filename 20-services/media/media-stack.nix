/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-025
 *   title: "Media Stack"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:427e550810c4fc6a1123f407bcc00dd73ab7e3d0c9aa5ecc8de4e5ecf04db336
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
