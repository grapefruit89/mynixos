/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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
 *   checksum: sha256:7b0867f71036798745fecef416e7587bd3c1a23766ee1a8f795cfd149995b2f3
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
