/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-013
 *   title: "Readeck"
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
 *   checksum: sha256:0ee5112484f4635fa3802b5c136ea961f7af3737d2dd17efac0b0497cec7c1d7
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
