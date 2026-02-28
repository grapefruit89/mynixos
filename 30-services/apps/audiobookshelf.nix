/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Audiobookshelf
 * TRACE-ID:     NIXH-SRV-003
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:3d80e9a41651bd84fcc52e74e7a696ad865aadb1f5eb17a63ce7d71f8eb1239c
 */

{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "audiobookshelf";
    useSSO = true;
    description = "Audiobook Server";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.audiobookshelf = {
      enable = true;
      host = "127.0.0.1";
      port = config.my.ports.audiobookshelf;
    };
  }
]
