/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-014
 *   title: "Scrutiny"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:59b3adb335c5546b7514bf2a86923b6a518c5283b4cdc0cef8380ca45b181efe
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
