/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-009
 *   title: "N8n"
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
 *   checksum: sha256:51d43edddb69c0389f3f249726b8278fdd2487a662d8e1f227cebcf0deb30721
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
