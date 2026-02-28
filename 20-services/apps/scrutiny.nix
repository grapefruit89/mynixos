/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Scrutiny HDD Monitoring
 * TRACE-ID:     NIXH-SRV-005
 * PURPOSE:      Visualisierung von S.M.A.R.T.-Werten der Festplatten.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/ports.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  cfg = config.my.profiles.services.scrutiny;
  serviceBase = myLib.mkService {
    inherit config;
    name = "scrutiny";
    useSSO = true;
    description = "Hard Drive Monitoring";
  };
in
lib.mkIf cfg.enable (lib.mkMerge [
  serviceBase
  {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = config.my.ports.scrutiny;
      };
    };

    systemd.services.scrutiny.serviceConfig = {
      DeviceAllow = [ "/dev/sda rw" "/dev/sdb rw" ];
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" ];
    };
  }
])
