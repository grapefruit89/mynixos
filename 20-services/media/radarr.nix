args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
}) args
