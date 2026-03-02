/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-027
 *   title: "Radarr (SRE Exhausted)"
 *   layer: 20
 * summary: Movie management safely locked inside a network namespace with resource guarding.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
  useVpn = true;
  extraServiceConfig = {
    serviceConfig = {
      MemoryMax = "1.5G";
      Environment = [ "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false" ];
    };
  };
}) args
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
