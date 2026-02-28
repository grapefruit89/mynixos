/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-004
 *   title: "Filebrowser"
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
 *   checksum: sha256:24dfd443f2d0f13ae1892bb1b03dc985e5d730812a16c09a1fd10094a854a4b5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
