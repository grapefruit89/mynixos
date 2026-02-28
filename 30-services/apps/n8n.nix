/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        N8n
 * TRACE-ID:     NIXH-SRV-002
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:0aefd0fff8f97921f65b4792c9fb93483421f5ec976809c2f6b0eb3b357d6860
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
