/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Readeck
 * TRACE-ID:     NIXH-SRV-005
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:dca07740cb0e9cb8b270be004095bd496583fda3944fd5b945a6b05d132085cd
 */

{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "readeck";
    useSSO = true;
    description = "Read Later Service";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.readeck = {
      enable = true;
      settings = {
        host = "127.0.0.1";
        port = config.my.ports.readeck;
      };
    };
  }
]
