/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Miniflux RSS Reader
 * TRACE-ID:     NIXH-SRV-007
 * PURPOSE:      Schlanker, performanter RSS-Feed-Reader.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/ports.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "miniflux";
    useSSO = true;
    description = "RSS Reader";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString config.my.ports.miniflux}";
        CREATE_ADMIN = 0;
      };
    };
  }
]
