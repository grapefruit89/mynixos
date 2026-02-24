args@{ lib, ... }:
((import ./_lib.nix { inherit lib; }) {
  name = "prowlarr";
  port = 9696;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/prowlarr";
  supportsUserGroup = false;
}) args
