/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-028
 *   title: "Readarr"
 *   layer: 20
 * summary: E-book manager safely locked inside a network namespace.
 * ---
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "readarr";
      port = config.my.ports.readarr;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/readarr";
      useVpn = true; # 🚀 SRE Standard: VPN Confinement
    })
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
