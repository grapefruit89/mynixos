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
 *   checksum: sha256:821ed397c9ad2cb8bd4bdf9746e051399a59dd9fa1a29ed4c2cca836f185c5b4
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
