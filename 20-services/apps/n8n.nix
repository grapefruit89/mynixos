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
{ config, lib, pkgs, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  domain = config.my.configs.identity.domain;
  
  serviceBase = myLib.mkService {
    inherit config;
    name = "n8n";
    useSSO = false;
    description = "Workflow Automation (Declarative Core)";
  };
in
lib.mkMerge [
  serviceBase
  {
    # 🚀 N8N EXHAUSTION
    services.n8n = {
      enable = true;
      
      # DEKLARATIVE COMMUNITY NODES
      # Nutzt withPackages Pattern um Nodes als Nix-Artefakte zu binden
      package = pkgs.n8n.withPackages (ps: [
        # Hier können Community Nodes hinzugefügt werden sobald verpackt
      ]);

      environment = {
        N8N_PORT = toString config.my.ports.n8n;
        N8N_HOST = "127.0.0.1";
        N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
        
        # SRE PERFORMANCE & DATA HYGIENE
        EXECUTIONS_DATA_PRUNE = "true";
        EXECUTIONS_DATA_MAX_AGE = "336"; # 14 Tage (Voll-Deklarativ)
        N8N_LOG_LEVEL = "info";
        
        # 🛡️ SECURE SECRET HANDLING
        # Verweist direkt auf sops-entschlüsselte Dateien (Kein Env-Leak)
        # N8N_ENCRYPTION_KEY_FILE = config.sops.secrets.n8n_enc_key.path;
      };
    };

    # systemd Hardening
    systemd.services.n8n.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/data/state/n8n" ];
      # Ermöglicht Zugriff auf Secrets falls _FILE genutzt wird
      # ReadOnlyPaths = [ config.sops.secrets.n8n_enc_key.path ];
    };
  }
]


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:e1e12eaa30d435098bc60f18cdc9bb858935fa46320c9af37c59b90fa54bd008
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
