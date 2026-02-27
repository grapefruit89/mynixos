{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.paperless;
  serviceBase = myLib.mkService {
    inherit config;
    name = "paperless";
    port = port;
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
      port = port;
    };
  }
]
