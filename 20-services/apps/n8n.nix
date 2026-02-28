/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-20-APP-SRV-009
 *   title: "N8n"
 *   layer: 20
 *   req_refs: [REQ-SRV]
 *   status: stable
 * traceability:
 *   parent: NIXH-20-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:51d43edddb69c0389f3f249726b8278fdd2487a662d8e1f227cebcf0deb30721"
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
