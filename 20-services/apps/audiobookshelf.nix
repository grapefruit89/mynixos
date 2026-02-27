{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.audiobookshelf;
  serviceBase = myLib.mkService {
    inherit config;
    name = "audiobookshelf";
    port = port;
    useSSO = false;
    description = "Audiobook Server";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.audiobookshelf = {
      enable = true;
      host = "127.0.0.1";
      port = port;
    };
  }
]
