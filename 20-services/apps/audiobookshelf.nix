/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "Audiobookshelf"
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
    name = "audiobookshelf";
    useSSO = true;
    description = "Audiobook Server";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.audiobookshelf = {
      enable = true;
      host = "127.0.0.1";
      port = config.my.ports.audiobookshelf;
    };
  }
]


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:d85c026f695ad6983ebbb62257baeff990fad27f7580f208ac471f3f4938a7ee
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
