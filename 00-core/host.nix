# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: host Modul (delegiert an zentrale configs)

{ config, ... }:
{
  # source-id: CFG.identity.host
  # sink: system hostname
  networking.hostName = config.my.configs.identity.host;
}
