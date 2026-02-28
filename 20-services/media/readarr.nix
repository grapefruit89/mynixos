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
 *   checksum: sha256:0bc0e097def68e259b36276ad27f9e4a7b6657483726ba2a0625e7eb90666e84
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
