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
 *   checksum: sha256:8a03fc6eaa005f1362e3a8796b114b125096f39ef4fe5e52b17d0ad8fb8006d1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
