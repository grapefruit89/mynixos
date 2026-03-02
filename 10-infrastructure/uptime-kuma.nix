/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-016
 *   title: "Uptime Kuma (SRE Exhausted)"
 *   layer: 10
 * summary: Self-hosted monitoring tool, tightly sandboxed with resource limits.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/uptime-kuma.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.uptimeKuma;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 UPTIME KUMA EXHAUSTION
  services.uptime-kuma = {
    enable = true;
    # SSoT: Port über Zentrale Registry
    settings.PORT = toString port;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."status.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: Exhausted) ──────────────────────────────────
  systemd.services.uptime-kuma.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    
    # Uptime Kuma braucht nur Netzwerk-Zugriff für Pings
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_RAW" ];
    
    # Aviation Grade Hardening
    LockPersonality = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    
    # Resources
    MemoryMax = "512M";
    CPUWeight = 30;
    OOMScoreAdjust = 500;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
