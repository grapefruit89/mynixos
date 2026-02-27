{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  cfg = config.my.profiles.services.scrutiny;
  serviceBase = myLib.mkService {
    inherit config;
    name = "scrutiny";
    useSSO = false;
    description = "Hard Drive Monitoring";
  };
in
lib.mkIf cfg.enable (lib.mkMerge [
  serviceBase
  {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = config.my.ports.scrutiny;
      };
    };

    systemd.services.scrutiny.serviceConfig = {
      DeviceAllow = [ "/dev/sda rw" "/dev/sdb rw" ];
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" ];
    };
  }
])
