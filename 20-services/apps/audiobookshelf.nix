{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "audiobookshelf";
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
      port = config.my.ports.audiobookshelf;
    };
  }
]
