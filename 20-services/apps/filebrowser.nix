/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-004
 *   title: "Filebrowser"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  cfg = config.my.profiles.services.filebrowser;
  serviceBase = myLib.mkService {
    inherit config;
    name = "filebrowser";
    useSSO = false;
    description = "Web File Manager";
  };
in
lib.mkIf cfg.enable (lib.mkMerge [
  serviceBase
  {
    services.filebrowser = {
      enable = true;
      settings = {
        port = config.my.ports.filebrowser;
        address = "127.0.0.1";
        root = "/mnt/storage";
      };
    };

    systemd.services.filebrowser.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ 
        "/var/lib/filebrowser"
        "/mnt/storage" 
      ];
    };
  }
])

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:716a7bbcc1b1fa7dd8d39528449ec4e543aa8d35ea30f9b3dd46a891107ce267
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
