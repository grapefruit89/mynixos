/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-011
 *   title: "Netdata (SRE Exhaustion)"
 *   layer: 10
 * summary: Real-time performance monitoring with high-retention dbengine and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/netdata.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.netdata;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 NETDATA EXHAUSTION
  services.netdata = {
    enable = true;
    
    # ── VOLL-DEKLARATIVE CONFIG (SRE Optimized) ──────────────────────────
    config = {
      global = {
        "memory mode" = "dbengine";
        "page cache size" = "256"; # MB (Optimiert für 16GB RAM)
        "dbengine disk space" = "4096"; # 4GB Disk-Speicher für Metriken
        "history" = 86400; # 24 Stunden High-Res
      };
      web = {
        "allow connections from" = "localhost 127.0.0.1";
        "default port" = toString port;
        "mode" = "static-threaded"; # Performance Boost
      };
      db = {
        "dbengine tier 1 retention days" = 30; # SRE: Langzeit-Metriken (30 Tage)
      };
      # SRE: Health Monitoring (Alarme)
      health = {
        "enabled" = "yes";
      };
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."netdata.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
  
  # ── SRE SANDBOXING (Level: Exhausted) ──────────────────────────────────
  systemd.services.netdata.serviceConfig = {
    ProtectSystem = "full";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    # SRE: Nur absolut notwendige Capabilities
    CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
    
    # Ressourcen-Limitierung (Monitoring darf System nicht lahmlegen)
    MemoryMax = "1G";
    CPUWeight = 50;
    OOMScoreAdjust = 1000; # Monitoring darf im Notfall zuerst sterben
    
    # Hardening
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
