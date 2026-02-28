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
 *   checksum: sha256:59f13cef1cc2d7457ff6fb3170e68a0ceff90234ea09e71aa6cfd3ebae9c765f
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
