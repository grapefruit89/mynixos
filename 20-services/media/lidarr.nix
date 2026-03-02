/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-024
 *   title: "Lidarr (SRE Exhausted)"
 *   layer: 20
 * summary: Music management safely locked inside a network namespace with resource guarding.
 * ---
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "lidarr";
      port = config.my.ports.lidarr or 8686;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/lidarr";
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
