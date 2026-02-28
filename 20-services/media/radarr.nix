/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-027
 *   title: "Radarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:87712ef124a2c55a833bea1d25aba9669de44ea2c04a2391c7c1cdaea6d127ce
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
