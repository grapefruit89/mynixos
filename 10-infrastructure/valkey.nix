/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-017
 *   title: "Valkey"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:541a6a6cb1e485d88f9e0367e1f55c6cb08a6bafa03827fe3b736bb4b45b3c77
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
