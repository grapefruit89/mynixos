{ pkgs, lib, ... }:
{
  # source: pkgs.valkey + services.redis.servers.valkey
  # sink:   local valkey on 127.0.0.1:6379 for internal apps
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
