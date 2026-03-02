/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-011
 *   title: "Netdata (SRE Hardened)"
 *   layer: 10
 * summary: Real-time performance monitoring with dbengine storage and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/netdata.nix
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../lib/helpers.nix { inherit lib; };
  port = config.my.ports.netdata;
  serviceBase = myLib.mkService {
    inherit config;
    name = "netdata";
    port = port;
    useSSO = true;
    description = "Real-time performance monitoring (Exhausted)";
  };
in
lib.mkMerge [
  serviceBase
  {
    # 🚀 NETDATA EXHAUSTION
    services.netdata = {
      enable = true;
      
      # VOLL-DEKLARATIVE CONFIG
      config = {
        global = {
          "memory mode" = "dbengine";
          "history" = 86400; # 24 Stunden Historie
        };
        web = {
          "allow connections from" = "localhost 127.0.0.1";
          "default port" = toString port;
        };
        db = {
          "dbengine tier 1 retention days" = 7; # SRE: Retention Policy
        };
      };
    };
    
    # systemd Hardening
    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full";
      # SRE: Nur absolut notwendige Capabilities
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      OOMScoreAdjust = 1000; # Monitoring darf im Notfall zuerst sterben
    };
  }
]
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
