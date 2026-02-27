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
