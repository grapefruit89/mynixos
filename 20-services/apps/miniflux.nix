{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.miniflux;
  serviceBase = myLib.mkService {
    inherit config;
    name = "miniflux";
    port = port;
    useSSO = false;
    description = "RSS Reader";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString port}";
        CREATE_ADMIN = 0;
      };
    };
  }
]
