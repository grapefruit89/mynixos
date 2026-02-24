args@{ lib, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "jellyfin";
  port = 8096;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/jellyfin";
}) args
