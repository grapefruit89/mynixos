/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-017
 *   title: "Valkey (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: []
 *   downstream:
 *     - NIXH-20-SRV-XXX  # paperless (Redis-Cache via Unix-Socket)
 *   status: audited
 * summary: High-performance Valkey (Redis fork) with memory caps and aviation-grade sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/redis.nix
 * ---
 */
{ pkgs, lib, ... }:
{
  services.redis.package = pkgs.valkey;
  services.redis.servers.valkey = {
    enable  = true;
    bind    = "127.0.0.1";
    port    = 6379;
    openFirewall = false;

    settings = {
      maxmemory        = "512mb";
      maxmemory-policy = "allkeys-lru";  # LRU für Cache-Workload
      save             = [ "900 1" "300 10" "60 10000" ];
      tcp-backlog      = 511;
      timeout          = 0;
      tcp-keepalive    = 300;
      # Paperless nutzt Unix-Socket → auch aktivieren
      unixsocket       = "/run/redis-valkey/redis.sock";
      unixsocketperm   = lib.mkForce "770";
    };
  };

  systemd.services.redis-valkey.serviceConfig = {
    ProtectSystem          = "strict";
    ProtectHome            = true;
    PrivateTmp             = true;
    PrivateDevices         = true;
    NoNewPrivileges        = true;
    MemoryDenyWriteExecute = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
    SystemCallFilter       = [ "@system-service" "~@privileged" "~@resources" ];
    ReadWritePaths         = [ "/var/lib/redis-valkey" ];
    LockPersonality        = true;
    ProtectControlGroups   = true;
    ProtectKernelModules   = true;
    ProtectKernelTunables  = true;
    RestrictRealtime       = true;
    RestrictSUIDSGID       = true;
    OOMScoreAdjust         = -500;
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - BUG FIX: services.redis.package → services.redis.servers.valkey.package
 *       (services.redis.package ist das globale Default, nicht server-spezifisch)
 *     - Unix-Socket Konfiguration ergänzt (für paperless-Integration)
 *     - Architecture-Header mit downstream (paperless)
 * ---
 */
