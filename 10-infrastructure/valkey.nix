/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-017
 *   title: "Valkey"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ pkgs, lib, ... }:
{
  services.redis = {
    package = pkgs.valkey;

    servers.valkey = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
      openFirewall = false;
    };
  };
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:6c8396550389a6a92590af604ecb0e831a4b14353a21ecf19a648365f2658453
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
