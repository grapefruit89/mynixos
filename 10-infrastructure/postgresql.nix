/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-018
 *   title: "PostgreSQL (SRE Optimized)"
 *   layer: 10
 * summary: Optimized database cluster with automated backups and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    # ── VERSION & PACKAGE ──────────────────────────────────────────────────
    package = pkgs.postgresql_17; # Upgrade auf Version 17 (NixOS 25.11 Standard)
    
    # ── DATA INTEGRITY ────────────────────────────────────────────────────
    initdbArgs = [ "--data-checksums" ]; # Schutz vor schleichender Datenkorruption
    
    # ── DEKLARATIVE DB-VERWALTUNG ──────────────────────────────────────────
    ensureDatabases = [ "miniflux" "paperless" "n8n" ];
    ensureUsers = [
      { name = "miniflux"; ensureDBOwnership = true; }
      { name = "paperless"; ensureDBOwnership = true; }
      { name = "n8n"; ensureDBOwnership = true; }
    ];

    # ── PERFORMANCE TUNING (Lean SRE v2.4 / 16GB RAM) ────────────────────
    enableJIT = true; # Performance-Boost bleibt aktiv
    settings = {
      # Memory Tuning (Konservativ für Mixed-Workload)
      shared_buffers = "512MB";         # Reserviert weniger festen RAM
      effective_cache_size = "4GB";     # Schätzung für den OS-Cache
      maintenance_work_mem = "128MB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;           # SSD Optimierung
      effective_io_concurrency = 200;
      work_mem = "8MB";                 # Reicht für Home-Apps völlig aus
      min_wal_size = "512MB";
      max_wal_size = "2GB";
      huge_pages = "try";
      
      # Logging (Fließt ins zentrale Journal)
      log_min_duration_statement = 250; # Reduziert Noise, loggt nur langsame Queries
      log_checkpoints = "on";
      log_connections = "on";
      log_disconnections = "on";
      log_lock_waits = "on";
      log_temp_files = 0;
      log_autovacuum_min_duration = 0;
    };
  };

  # ── AUTOMATISCHE BACKUPS (NixOS Native) ──────────────────────────────────
  # Erzeugt täglich SQL-Dumps nach /var/lib/postgresql/backups
  services.postgresqlBackup = {
    enable = true;
    databases = [ "miniflux" "paperless" "n8n" ];
    location = "/data/state/backups/postgresql";
    startAt = "01:30"; # Kurz vor dem Restic-Lauf
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.postgresql.serviceConfig = {
    # Aus nixpkgs übernommen: Maximale Isolation
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    # OOM-Schutz: Datenbank ist kritisch
    OOMScoreAdjust = -900;
  };

  # Abhängigkeiten sicherstellen
  systemd.services.miniflux.after = [ "postgresql.service" ];
  systemd.services.paperless.after = [ "postgresql.service" ];
  systemd.services.n8n.after = [ "postgresql.service" ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
