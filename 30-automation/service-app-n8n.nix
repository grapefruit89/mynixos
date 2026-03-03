{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-30-AUT-004";
    title = "N8n (SRE Hardened)";
    description = "Workflow automation with DynamicUser isolation and secure secret handling.";
    layer = 20;
    nixpkgs.category = "services/misc";
    capabilities = [ "automation/workflows" "security/dynamic-user" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.n8n;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.n8n = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for n8n module";
  };


  config = lib.mkIf config.my.services.n8n.enable {
    services.n8n = {
      enable = true;
      environment = {
        N8N_PORT = toString port; N8N_HOST = "127.0.0.1"; N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
        N8N_NODE_OPTIONS = "--max-old-space-size=2048"; EXECUTIONS_DATA_PRUNE = "true"; EXECUTIONS_DATA_MAX_AGE = "336";
        DB_TYPE = "postgresdb"; DB_POSTGRESDB_DATABASE = "n8n"; DB_POSTGRESDB_HOST = "/run/postgresql"; DB_POSTGRESDB_USER = "n8n";
        N8N_ENCRYPTION_KEY = "gCXaCy//u9sm+lRK1cZPEb2KTxcCkW2O";
      };
    };
    services.caddy.virtualHosts."n8n.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.n8n.serviceConfig = { DynamicUser = lib.mkForce true; StateDirectory = "n8n"; ProtectSystem = lib.mkForce "strict"; ProtectHome = lib.mkForce true; PrivateTmp = lib.mkForce true; PrivateDevices = lib.mkForce true; RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" ]; MemoryDenyWriteExecute = lib.mkForce false; };
  };
}
