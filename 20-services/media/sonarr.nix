/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-032
 *   title: "Sonarr (SRE Exhausted)"
 *   layer: 20
 * summary: TV show management safely locked inside a network namespace with resource guarding.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
  useVpn = true;
  extraServiceConfig = {
    # 🚀 SRE Stabilität: Schutz vor Memory-Leaks (Mono/.NET)
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
