/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Sabnzbd Downloader
 * TRACE-ID:     NIXH-SRV-010
 * PURPOSE:      Hochperformanter Usenet-Downloader (Netns-Bound).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
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
    })
  ];
  config = {
    users.groups.sabnzbd.gid = lib.mkForce 194;
    users.users.sabnzbd.uid = lib.mkForce 984;
    systemd.services.sabnzbd = {
      requires = lib.mkForce [ "wireguard-vault.service" ];
      after = lib.mkForce [ "wireguard-vault.service" ];
    };
  };
}
