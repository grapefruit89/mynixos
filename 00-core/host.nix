/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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
 *   checksum: sha256:8aa1c59b11f7745e9bdf3cc7865eb3e6f5a61493bc1d064b98569665d6238e87
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
