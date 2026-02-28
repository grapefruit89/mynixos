/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-026
 *   title: "Prowlarr"
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
  name = "prowlarr";
  port = config.my.ports.prowlarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/prowlarr";
  supportsUserGroup = false;
}) args





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:28f655d6a5298a85f735bf282395278985b1f2635da722f33df33dc5a7ec57e8
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
