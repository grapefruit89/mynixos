/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-002
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
 *   checksum: sha256:72cee498f89294ad4d850e12156ba57051ddc179439d070adc9457b0f44765f5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
