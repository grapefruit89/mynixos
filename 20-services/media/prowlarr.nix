/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-026
 *   title: "Prowlarr"
 *   layer: 20
 * summary: Indexer manager safely locked inside a network namespace.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "prowlarr";
  port = config.my.ports.prowlarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/prowlarr";
  supportsUserGroup = false;
  useVpn = true; # 🚀 SRE Standard: VPN Confinement
}) args
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
