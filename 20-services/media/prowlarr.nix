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
 *   checksum: sha256:24b907e174a323af0552eb90ed7e9ad2721361ad0d821ef6fe44f8eb861675df
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
