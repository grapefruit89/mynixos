args@{ lib, config, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
}) args
