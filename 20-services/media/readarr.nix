{ lib, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "readarr";
      port = 8787;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/readarr";
    })
  ];
}
