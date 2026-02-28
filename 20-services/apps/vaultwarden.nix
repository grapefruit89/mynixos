/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-017
 *   title: "Vaultwarden"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "vaultwarden";
    useSSO = false;
    description = "Password Manager";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.ports.vaultwarden;
      };
    };

    systemd.services.vaultwarden.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/vaultwarden" ];
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
    };
  }
]

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:9a82c6795d35abaf01b9ba9a7ed95950df95c13225a498f1f1423869a4c5429e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
