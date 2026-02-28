/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-028
 *   title: "Readarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:24665766d80eb75130bcd9247293c51d4d1f91a310313089383f5602b28f3dfb
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
