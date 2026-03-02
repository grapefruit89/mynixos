/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-032
 *   title: "Sonarr"
 *   layer: 20
 * summary: TV show management safely locked inside a network namespace.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
  useVpn = true; # 🚀 SRE Standard: VPN Confinement
}) args
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
