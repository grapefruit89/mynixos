/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-012
 *   title: "Paperless"
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
 *   checksum: sha256:54a4ac54cad4c9befa1f3207b00c5df9869338c5864fa537b21df6f5e26cbb5f
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
