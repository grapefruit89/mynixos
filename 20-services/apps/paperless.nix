/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-012
 *   title: "Paperless"
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
    name = "paperless";
    useSSO = false;
    description = "Document Management System";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = config.my.ports.paperless;
    };
  }
]












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:f87d551b993481ea5955b0d9efa293cc72e40651cadc3f643ed94b9fa6bc0af4
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
