/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-20-APP-SRV-020
 *   title: "Default"
 *   layer: 20
 *   req_refs: [REQ-SRV]
 *   status: stable
 * traceability:
 *   parent: NIXH-20-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:7342e40e71c4ddb7103ddd84db94649010fe00bfaceab1a3b3efd0c8b952f0e1"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
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
