{ config, lib, ... }:
let
  myLib = import ../lib/helpers.nix { inherit lib; };
  port = config.my.ports.netdata;
  serviceBase = myLib.mkService {
    inherit config;
    name = "netdata";
    port = port;
    useSSO = true; # Admin monitoring needs protection
    description = "Real-time performance monitoring";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.netdata.enable = true;
    
    # Overrides for Netdata
    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full"; # Needs some access
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" ];
    };
  }
]
