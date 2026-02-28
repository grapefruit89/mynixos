/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-011
 *   title: "Host"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
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
 *   checksum: sha256:2581f497b390916729b62047d736ac09e9cd2520c34cbbaceea7f9c34513adc8
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
