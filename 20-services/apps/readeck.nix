/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-013
 *   title: "Readeck"
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
    name = "readeck";
    useSSO = true;
    description = "Read Later Service";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.readeck = {
      enable = true;
      settings = {
        host = "127.0.0.1";
        port = config.my.ports.readeck;
      };
    };
  }
]

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:86bf24b3fa4516e637a5b1251c909832355201369c4430d52fd906de6110ba21
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
