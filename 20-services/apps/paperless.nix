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
      
      # Use local Postgres configuration
      database.createLocally = true;
      
      # Tika and Gotenberg for Office documents
      settings = {
        PAPERLESS_TIKA_ENABLED = 1;
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://localhost:9998";
      };
      
      # Password / Secret
      passwordFile = config.sops.secrets.paperless_secret_key.path;
    };

    services.gotenberg = {
      enable = true;
      port = 3000;
    };

    services.tika = {
      enable = true;
      port = 9998;
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
