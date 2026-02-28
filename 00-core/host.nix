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
 *   checksum: sha256:deafd80f13cb6f4afd17cb39045fcc2491cfcaeed62f8b88dd9718a3c16beeda
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
