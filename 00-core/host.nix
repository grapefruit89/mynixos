# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: host/identity Modul

{ lib, config, ... }:
{
  options.my.identity = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "moritz";
      description = "Primary interactive user for SSH/login defaults.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "nixhome";
      description = "System hostname.";
    };
  };

  config = {
    networking.hostName = config.my.identity.host;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      openFirewall = false;
    };
  };
}
