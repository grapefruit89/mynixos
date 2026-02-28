/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-007
 *   title: "Miniflux"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "miniflux";
    useSSO = true;
    description = "RSS Reader";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString config.my.ports.miniflux}";
        CREATE_ADMIN = 0;
      };
    };
  }
]












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:0a2e5ebc20e5cee1a4ab89e430db42a9ce171f18ebea18b718c2a34ef3fb9277
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
