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
 *   checksum: sha256:921f28183cdf3eb3894db2693b9d5400fd9f4eeabc940cc3bd98200c486f5dec
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
