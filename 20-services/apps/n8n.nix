/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-009
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
  domain = config.my.configs.identity.domain;
  
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
      
      # 🚀 DEKLARATIVE COMMUNITY NODES
      # Ermöglicht reproduzierbare Erweiterungen ohne UI-Installation.
      # customNodes = [ pkgs.n8n-nodes-custom-example ]; 

      environment = {
        N8N_PORT = toString config.my.ports.n8n;
        N8N_HOST = "127.0.0.1";
        N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
        
        # SRE: Optimiertes Pruning & Performance
        EXECUTIONS_DATA_PRUNE = "true";
        EXECUTIONS_DATA_MAX_AGE = "336"; # 14 Tage
        
        # 🛡️ SICHERES SECRET HANDLING
        # Nutzt SOPS-Secrets direkt über Dateipfade (systemd-credentials kompatibel)
        # N8N_ENCRYPTION_KEY_FILE = config.sops.secrets.n8n_enc_key.path;
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
 *   checksum: sha256:ad9fddcaea447564eb6216c2d5e1e3f124727d1b480a055fd3baacf50c20778e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
