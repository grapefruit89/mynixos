args@{ lib, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "radarr";
  port = 7878;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
}) args
