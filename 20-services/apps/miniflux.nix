{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  # port is now automatically looked up in config.my.ports.miniflux
  serviceBase = myLib.mkService {
    inherit config;
    name = "miniflux";
    useSSO = true;
    description = "RSS Reader";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.miniflux = {
      enable = true;
      config = {
        # Still using config.my.ports here for the service itself, 
        # but the Traefik routing is now abstracted.
        LISTEN_ADDR = "127.0.0.1:${toString config.my.ports.miniflux}";
        CREATE_ADMIN = 0;
      };
    };
  }
]
