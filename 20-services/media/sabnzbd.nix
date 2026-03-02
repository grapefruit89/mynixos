/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-030
 *   title: "Sabnzbd"
 *   layer: 20
 * summary: Usenet downloader with Nixarr-style VPN Confinement.
 * ---
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "sabnzbd";
      port = config.my.ports.sabnzbd;
      stateOption = "configFile";
      defaultStateDir = "/var/lib/sabnzbd";
      statePathSuffix = "sabnzbd.ini";
      useVpn = true; # 🚀 NUTZT JETZT DAS NEUE LIB-FEATURE
    })
  ];
  
  config = {
    # Keine manuelle Namespace-Logik mehr nötig, wird über _lib.nix geregelt!
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
