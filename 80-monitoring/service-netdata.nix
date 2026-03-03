{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-011";
    title = "Netdata (SRE Exhausted)";
    description = "Real-time performance monitoring with high-retention dbengine and strict sandboxing.";
    layer = 80;
    nixpkgs.category = "services/monitoring";
    capabilities = [ "monitoring/real-time" "observability/metrics" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.netdata;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.netdata = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for netdata module";
  };


  config = lib.mkIf config.my.services.netdata.enable {
    services.netdata = {
      enable = true;
      config = {
        global = { "memory mode" = "dbengine"; "page cache size" = "256"; "dbengine disk space" = "4096"; "history" = 86400; };
        web = { "allow connections from" = "localhost 127.0.0.1"; "default port" = toString port; "mode" = "static-threaded"; };
        db = { "dbengine tier 1 retention days" = 30; };
        health.enabled = "yes";
      };
    };
    services.caddy.virtualHosts."netdata.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full"; ProtectHome = lib.mkForce true; PrivateTmp = lib.mkForce true; PrivateDevices = lib.mkForce true;
      NoNewPrivileges = true; CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ]; AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      MemoryMax = "1G"; CPUWeight = 50; OOMScoreAdjust = 1000;
    };
  };
}
