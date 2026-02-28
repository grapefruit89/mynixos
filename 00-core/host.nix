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
 *   checksum: sha256:315f9f1db79c47ef6fc95b91571f6b543e662c448d017ad410cb1ca4c7152750
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
