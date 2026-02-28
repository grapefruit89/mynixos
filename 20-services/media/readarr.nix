/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-028
 *   title: "Readarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "readarr";
      port = config.my.ports.readarr;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/readarr";
    })
  ];
}











/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8f11ddb055b81fe11a21ef609b4e2f47a3be28c7407f8046c1cc8e44fc0e920d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
