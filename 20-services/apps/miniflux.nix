/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-007
 *   title: "Miniflux"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:549122c50b18b2b65d33fcd3d6ecae4eb5c011fb907afd32b2562818fa5be894
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
