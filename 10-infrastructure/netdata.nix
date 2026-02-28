/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Netdata Performance Monitoring
 * TRACE-ID:     NIXH-INF-015
 * PURPOSE:      Real-time System-Metriken & Dashboard.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
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
