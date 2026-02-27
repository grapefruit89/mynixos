{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.readeck;
  serviceBase = myLib.mkService {
    inherit config;
    name = "readeck";
    port = port;
    useSSO = false;
    description = "Read Later Service";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.readeck = {
      enable = true;
      settings = {
        host = "127.0.0.1";
        port = port;
      };
    };
  }
]
