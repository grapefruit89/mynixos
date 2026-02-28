/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-020
 *   title: "Default"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:7342e40e71c4ddb7103ddd84db94649010fe00bfaceab1a3b3efd0c8b952f0e1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
