{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-INF-002";
    title = "PostgreSQL (SRE Optimized)";
    description = "Optimized database cluster with automated backups and strict sandboxing.";
    layer = 10;
    nixpkgs.category = "services/databases";
    capabilities = [ "database/postgresql" "system/persistence" "maintenance/auto-backup" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.postgresql = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for postgresql module";
  };


  config = lib.mkIf config.my.services.postgresql.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
      initdbArgs = [ "--data-checksums" ];
      ensureDatabases = [ "miniflux" "paperless" "n8n" ];
      ensureUsers = [ { name = "miniflux"; ensureDBOwnership = true; } { name = "paperless"; ensureDBOwnership = true; } { name = "n8n"; ensureDBOwnership = true; } ];
      enableJIT = true;
      settings = {
        shared_buffers = "512MB"; effective_cache_size = "4GB"; maintenance_work_mem = "128MB"; checkpoint_completion_target = 0.9;
        wal_buffers = "16MB"; default_statistics_target = 100; random_page_cost = 1.1; effective_io_concurrency = 200;
        work_mem = "8MB"; min_wal_size = "512MB"; max_wal_size = "2GB"; huge_pages = "try";
        log_min_duration_statement = 250; log_checkpoints = "on"; log_connections = "on"; log_disconnections = "on"; log_lock_waits = "on";
      };
    };
    services.postgresqlBackup = { enable = true; databases = [ "miniflux" "paperless" "n8n" ]; location = "/data/state/backups/postgresql"; startAt = "01:30"; };
    systemd.services.postgresql.serviceConfig = { ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true; SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ]; OOMScoreAdjust = -900; };
    systemd.services.miniflux.after = [ "postgresql.service" ];
    systemd.services.n8n.after = [ "postgresql.service" ];
    systemd.services.paperless-web.after = [ "postgresql.service" ];
  };
}
