/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "N8n"
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
    name = "n8n";
    useSSO = false;
    description = "Workflow Automation";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.n8n = {
      enable = true;
      environment = {
        N8N_PORT = toString config.my.ports.n8n;
        N8N_HOST = "127.0.0.1";
        N8N_EDITOR_BASE_URL = "https://n8n.${config.my.configs.identity.domain}";
        EXECUTIONS_DATA_PRUNE = "true";
        EXECUTIONS_DATA_MAX_AGE = "336";
      };
    };

    systemd.services.n8n.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/data/state/n8n" ];
    };
  }
]


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:6f137cb0cb326f46387d2d53718c82c857daa518e770e81c45752a1b6bb4569b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
