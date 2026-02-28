/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-027
 *   title: "Radarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
}) args









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:98fe974ce8096324d990990d8f4c0994bc84136efbbddc99faa28168b5d77bb1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
