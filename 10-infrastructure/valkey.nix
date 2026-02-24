{ pkgs, lib, ... }:
{
  # Native Valkey via the Redis NixOS module.
  services.redis = {
    package = pkgs.valkey;

    servers.valkey = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
      openFirewall = false;
    };
  };
}
