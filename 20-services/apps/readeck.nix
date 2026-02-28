/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-20-APP-SRV-013
 *   title: "Readeck"
 *   layer: 20
 *   req_refs: [REQ-SRV]
 *   status: stable
 * traceability:
 *   parent: NIXH-20-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:86bf24b3fa4516e637a5b1251c909832355201369c4430d52fd906de6110ba21"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
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
