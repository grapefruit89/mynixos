/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-030
 *   title: "Sabnzbd (SRE Exhausted)"
 *   layer: 20
 * summary: Usenet downloader with Nixarr-style VPN Confinement and resource guarding.
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
      useVpn = true;
      extraServiceConfig = {
        serviceConfig = {
          # 🚀 SRE Performance: Usenet braucht CPU-Power für Entpacken
          CPUWeight = 100;
          MemoryMax = "2G";
          # Schutz vor Dateisystem-Exploits
          ProtectProc = "invisible";
          ProcSubset = "pid";
        };
      };
    })
  ];
  
  # 🚀 OPTIONS EXHAUSTION
  services.sabnzbd = {
    user = "sabnzbd";
    group = "media";
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
