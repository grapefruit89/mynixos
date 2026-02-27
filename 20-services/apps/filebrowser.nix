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
