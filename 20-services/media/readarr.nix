{ lib, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "readarr";
      port = config.my.ports.readarr;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/readarr";
    })
  ];
}
