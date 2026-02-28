/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-032
 *   title: "Sonarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
}) args

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:a3304bf8ffa1f0fcd79a731c6abb5b8a2c7e3f2dace88a701945754f922df720
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
