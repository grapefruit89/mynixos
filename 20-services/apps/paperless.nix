/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Paperless-ngx
 * TRACE-ID:     NIXH-SRV-020
 * PURPOSE:      Digitales Dokumentenmanagementsystem.
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
    name = "paperless";
    useSSO = false;
    description = "Document Management System";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = config.my.ports.paperless;
    };
  }
]
