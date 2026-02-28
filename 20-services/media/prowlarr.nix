/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-026
 *   title: "Prowlarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:8fe3b95dbf3b9bd6923689410fc682796844f4c7065243bbac41d343a634c466
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
