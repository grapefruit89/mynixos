# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: host Modul (delegiert an zentrale configs)

{ config, lib, ... }:
{
  # source-id: CFG.identity.host
  # sink: system hostname
  networking.hostName = lib.mkForce config.my.configs.identity.host;
}
