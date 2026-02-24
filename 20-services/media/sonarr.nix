args@{ lib, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "sonarr";
  port = 8989;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
}) args
