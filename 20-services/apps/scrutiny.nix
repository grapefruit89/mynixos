/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-014
 *   title: "Scrutiny"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:0e92968750f69d206845a46b07a9bc08515aba1c6999de70e06b5708efe04b6e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
