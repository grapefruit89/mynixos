/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-002
 *   title: "Audiobookshelf"
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
 *   checksum: sha256:efda9629efc544d869b0036c1d7d5b1ad622b1dbe6f1f5dc28583243ef423235
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
