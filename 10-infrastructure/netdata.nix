/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-011
 *   title: "Netdata"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:9ef2b18bbc1fb3282630348448bc4f9f9720cd90eff7227112d6404836f24af1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
