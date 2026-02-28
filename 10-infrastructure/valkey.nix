/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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
 *   checksum: sha256:a3d18d67b2e3bdfecbd2801448115f6e0bd862a8a63548b74862f5a8002fc5f9
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
