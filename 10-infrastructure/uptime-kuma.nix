/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-016
 *   title: "Uptime Kuma (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * summary: Self-hosted monitoring tool, tightly sandboxed with resource limits.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/uptime-kuma.nix
 * ---
 */
{ config, ... }:
let
  # source: PORT.uptimeKuma → 00-core/ports.nix
  port   = config.my.ports.uptimeKuma;
  # source: CFG.identity.domain → 00-core/configs.nix
  domain = config.my.configs.identity.domain;
in
{
  services.uptime-kuma = {
    enable = true;
    settings.PORT = toString port;
  };

  services.caddy.virtualHosts."status.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  systemd.services.uptime-kuma.serviceConfig = {
    ProtectSystem         = "strict";
    ProtectHome           = true;
    PrivateTmp            = true;
    PrivateDevices        = true;
    NoNewPrivileges       = true;
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities   = [ "CAP_NET_RAW" ];
    LockPersonality       = true;
    ProtectControlGroups  = true;
    ProtectKernelModules  = true;
    ProtectKernelTunables = true;
    RestrictRealtime      = true;
    RestrictSUIDSGID      = true;
    SystemCallFilter      = [ "@system-service" "~@privileged" "~@resources" ];
    MemoryMax             = "512M";
    CPUWeight             = 30;
    OOMScoreAdjust        = 500;
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 1
 * ---
 */
