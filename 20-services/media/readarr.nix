/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-028
 *   title: "Readarr (SRE Exhausted)"
 *   layer: 20
 * summary: E-book manager safely locked inside a network namespace with resource guarding.
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
      useVpn = true;
      extraServiceConfig = {
        serviceConfig = {
          MemoryMax = "1G";
          Environment = [ "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false" ];
        };
      };
    })
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
