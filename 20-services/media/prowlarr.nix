/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-026
 *   title: "Prowlarr (SRE Exhausted)"
 *   layer: 20
 * summary: Indexer manager safely locked inside a network namespace with resource guarding.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "prowlarr";
  port = config.my.ports.prowlarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/prowlarr";
  supportsUserGroup = false;
  useVpn = true;
  extraServiceConfig = {
    serviceConfig = {
      MemoryMax = "1G";
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
