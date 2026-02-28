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
 *   checksum: sha256:f0d860b6d0127d45a6c44af1568d9048d4a55f3ad8533568703c6eb72e9ff514
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
