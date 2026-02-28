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
