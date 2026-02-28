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
 *   checksum: sha256:d77b395657c4e0d771a8964666d7c776480973bdb5b4b6071894628e4530900e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
