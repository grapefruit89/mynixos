/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-017
 *   title: "Valkey (SRE Exhausted)"
 *   layer: 10
 * summary: High-performance Valkey (Redis) with memory caps and aviation-grade sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/redis.nix
 * ---
 */
{ pkgs, lib, ... }:
{
  services.redis = {
    package = pkgs.valkey; # SSoT: Valkey statt Redis

    servers.valkey = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
      openFirewall = false;
      
      # ── MEMORY MANAGEMENT (SRE Standard) ──────────────────────────────────
      settings = {
        maxmemory = "512mb";
        maxmemory-policy = "allkeys-lru"; # Wirft am längsten ungenutzte Keys raus
        save = [ "900 1" "300 10" "60 10000" ]; # Kluge Snapshots
        # 🚀 Performance Tuning
        tcp-backlog = 511;
        timeout = 0;
        tcp-keepalive = 300;
      };
    };
  };

  # ── SRE SANDBOXING (Level: Exhausted) ──────────────────────────────────
  systemd.services.redis-valkey.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    MemoryDenyWriteExecute = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    ReadWritePaths = [ "/var/lib/redis-valkey" ];
    
    # Aviation Grade Hardening
    LockPersonality = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    
    # Valkey ist wichtig für Cache-Performance
    OOMScoreAdjust = -500;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
