/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-011
 *   title: "Host"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
{
  # source-id: CFG.identity.host
  networking.hostName = lib.mkForce config.my.configs.identity.host;
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:ee1cd9c5663a75d21133acf2f0c3f6abbc1bdffdae2f64b883ad4336b8fdf6ee
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
