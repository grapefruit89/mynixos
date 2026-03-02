/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-020
 *   title: "Default"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ ... }:
{
  imports = [
    ./service-media-services-common.nix
    ./service-media-arr-wire.nix
    ./service-media-jellyfin.nix
    ./service-media-jellyseerr.nix
    ./service-media-sonarr.nix
    ./service-media-radarr.nix
    ./service-media-lidarr.nix
    ./service-media-readarr.nix
    ./service-media-prowlarr.nix
    ./service-media-sabnzbd.nix
    ./service-media-recyclarr.nix
  ];
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:653ecf499149d7f44f0ce81ac9ecacfd1f7ab7d890f6254716006657c8ec850d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
