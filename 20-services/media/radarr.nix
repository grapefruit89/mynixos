/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-027
 *   title: "Radarr"
 *   layer: 20
 * summary: Movie management safely locked inside a network namespace.
 * ---
 */
args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
  useVpn = true; # 🚀 SRE Standard: VPN Confinement
}) args
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
