/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-009
 *   title: "N8n (SRE Hardened)"
 *   layer: 20
 * summary: Workflow automation with DynamicUser isolation and secure secret handling.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/n8n.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.n8n;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 N8N EXHAUSTION
  services.n8n = {
    enable = true;
    
    environment = {
      N8N_PORT = toString port;
      N8N_HOST = "127.0.0.1";
      N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
      
      # ── SRE PERFORMANCE & HYGIENE ────────────────────────────────────────
      N8N_NODE_OPTIONS = "--max-old-space-size=2048"; # Reserviert max 2GB RAM
      EXECUTIONS_DATA_PRUNE = "true";
      EXECUTIONS_DATA_MAX_AGE = "336"; # 14 Tage
      N8N_LOG_LEVEL = "info";
      
      # Worker Concurrency (Stabil auf i3-9100)
      N8N_CONCURRENCY_PRODUCTION_LIMIT = "5"; 
      
      # DB Wiring (Postgres aus Layer 10)
      DB_TYPE = "postgresdb";
      DB_POSTGRESDB_DATABASE = "n8n";
      DB_POSTGRESDB_HOST = "/run/postgresql";
      DB_POSTGRESDB_USER = "n8n";

              # 🛡️ SECURE SECRET HANDLING (Modern Pattern)

              # Wir nutzen das _FILE Pattern von nixpkgs, um Secrets sicher via systemd

              # credentials zu laden.

              N8N_ENCRYPTION_KEY_FILE = "/run/credentials/n8n.service/n8n_enc_key";

            };

      
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."n8n.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.n8n.serviceConfig = {
    # DynamicUser isoliert den Dienst pro Start (keine permanenten UIDs nötig)
    DynamicUser = lib.mkForce true;
    StateDirectory = "n8n"; # Mappt auf /var/lib/n8n
    
        ProtectSystem = lib.mkForce "strict";
        ProtectHome = lib.mkForce true;
        PrivateTmp = lib.mkForce true;
        PrivateDevices = lib.mkForce true;
        
        # n8n braucht Netzwerk für Webhooks
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        
        # MemoryDenyWriteExecute muss auf 'no' bleiben, da n8n/node JIT nutzt.
        MemoryDenyWriteExecute = lib.mkForce false; 
        # Verweist auf sops-Secrets via LoadCredential
    LoadCredential = [ "n8n_enc_key:${config.sops.secrets.n8n_enc_key.path}" ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
