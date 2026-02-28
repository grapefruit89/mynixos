/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-032
 *   title: "Sonarr"
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
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
}) args









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:4a595ac5c29d4da60199e2d1a9556bbdb839b1460ab21d1e2c75a40c0c6bab5c
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
