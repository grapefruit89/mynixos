/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-011
 *   title: "Netdata"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
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
      
      # VOLL-DEKLARATIVE CONFIG (Netdata Node Config)
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
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      OOMScoreAdjust = 1000; # Netdata darf im Extremfall zuerst sterben
    };
  }
]



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:ed62d7c1d886c87f2725f8b5fd716bcd8bc1cedfec32e7e96594a196d23c1c43
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
