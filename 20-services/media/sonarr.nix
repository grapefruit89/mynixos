args@{ lib, config, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
}) args
