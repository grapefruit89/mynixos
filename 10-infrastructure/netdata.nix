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
    description = "Real-time performance monitoring";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.netdata.enable = true;
    
    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full";
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" ];
    };
  }
]








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:b3c3fb32394776e9257c2ebeb6f618b642924e7d9c28d38f27ff47a0b9cd71cc
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
