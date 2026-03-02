/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-018
 *   title: "PostgreSQL (SRE Optimized)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006]
 *   downstream:
 *     - NIXH-20-SRV-XXX  # miniflux
 *     - NIXH-20-SRV-XXX  # paperless
 *     - NIXH-20-SRV-XXX  # n8n
 *   status: audited
 * summary: Optimized database cluster with automated backups and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  services.postgresql = {
    enable  = true;
    package = pkgs.postgresql_17;

    initdbArgs = [ "--data-checksums" ]; # Schutz vor schleichender Datenkorruption

    ensureDatabases = [ "miniflux" "paperless" "n8n" ];
    ensureUsers = [
      { name = "miniflux";  ensureDBOwnership = true; }
      { name = "paperless"; ensureDBOwnership = true; }
      { name = "n8n";       ensureDBOwnership = true; }
    ];

    enableJIT = true;
    settings = {
      # Memory (konservativ für Mixed-Workload auf 16GB)
      shared_buffers            = "512MB";
      effective_cache_size      = "4GB";
      maintenance_work_mem      = "128MB";
      checkpoint_completion_target = 0.9;
      wal_buffers               = "16MB";
      default_statistics_target = 100;
      random_page_cost          = 1.1;   # SSD
      effective_io_concurrency  = 200;
      work_mem                  = "8MB";
      min_wal_size              = "512MB";
      max_wal_size              = "2GB";
      huge_pages                = "try";

      # Logging
      log_min_duration_statement = 250;  # Nur langsame Queries (>250ms)
      log_checkpoints            = "on";
      log_connections            = "on";
      log_disconnections         = "on";
      log_lock_waits             = "on";
      log_temp_files             = 0;
      log_autovacuum_min_duration = 0;
    };
  };

  services.postgresqlBackup = {
    enable     = true;
    databases  = [ "miniflux" "paperless" "n8n" ];
    location   = "/data/state/backups/postgresql";
    startAt    = "01:30";  # Kurz vor dem Restic-Lauf (02:00)
  };

  systemd.services.postgresql.serviceConfig = {
    ProtectSystem    = "strict";
    ProtectHome      = true;
    PrivateTmp       = true;
    PrivateDevices   = true;
    NoNewPrivileges  = true;
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    OOMScoreAdjust   = -900; # Datenbank ist kritisch
  };

  # Service-Abhängigkeiten: alle DB-Nutzer müssen nach PostgreSQL starten
  systemd.services.miniflux.after = [ "postgresql.service" ];
  systemd.services.n8n.after      = [ "postgresql.service" ];

  # FIX: nixpkgs paperless definiert 4 Services. Der Web-Service heißt "paperless-web",
  # nicht "paperless". Sonst wird ein nicht-existenter Service referenziert.
  systemd.services.paperless-web.after = [ "postgresql.service" ];
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - BUG FIX: systemd.services.paperless → paperless-web (korrekter nixpkgs Service-Name)
 *     - Architecture-Header mit downstream-Dependencies
 *     - Kommentar für Backup-Timing (Restic-Koordination)
 * ---
 */
