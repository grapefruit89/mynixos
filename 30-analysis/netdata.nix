/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-011
 *   title: "Netdata (SRE Exhaustion)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * summary: Real-time performance monitoring with high-retention dbengine and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/netdata.nix
 * ---
 */
{ config, lib, ... }:
let
  # source: PORT.netdata  → 00-core/ports.nix
  port   = config.my.ports.netdata;
  # source: CFG.identity.domain → 00-core/configs.nix
  domain = config.my.configs.identity.domain;
in
{
  services.netdata = {
    enable = true;
    config = {
      global = {
        "memory mode"         = "dbengine";
        "page cache size"     = "256";
        "dbengine disk space" = "4096";
        "history"             = 86400;
      };
      web = {
        "allow connections from" = "localhost 127.0.0.1";
        "default port"           = toString port;
        "mode"                   = "static-threaded";
      };
      db = {
        "dbengine tier 1 retention days" = 30;
      };
      health.enabled = "yes";
    };
  };

  # Caddy-VirtualHost gehört in netdata.nix (nicht in sso.nix — war Duplikat)
  services.caddy.virtualHosts."netdata.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

      systemd.services.netdata.serviceConfig = {

        ProtectSystem         = lib.mkForce "full";

        ProtectHome           = lib.mkForce true;

        PrivateTmp            = lib.mkForce true;

        PrivateDevices        = lib.mkForce true;

  
    NoNewPrivileges       = true;
    CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
    AmbientCapabilities   = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
    MemoryMax             = "1G";
    CPUWeight             = 50;
    OOMScoreAdjust        = 1000;
    RestrictRealtime      = true;
    RestrictSUIDSGID      = true;
    ProtectControlGroups  = true;
    ProtectKernelModules  = true;
    ProtectKernelTunables = true;
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 1
 *   changes_from_previous:
 *     - Architecture-Header ergänzt
 *     - Kommentar: Caddy-VirtualHost gehört hier, nicht in sso.nix
 * ---
 */
