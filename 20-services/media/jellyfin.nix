/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Jellyfin Media Server
 * TRACE-ID:     NIXH-SRV-001
 * PURPOSE:      Main Media-Streaming Service (Hardware-Beschleunigung aktiv).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "jellyfin";
      port = config.my.ports.jellyfin;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/jellyfin";
    })
  ];

  config = lib.mkIf config.my.media.jellyfin.enable {
    users.users.jellyfin.extraGroups = [ "video" "render" ];
    systemd.services.jellyfin.serviceConfig = {
      PrivateDevices = lib.mkForce false;
      DeviceAllow = [ "/dev/dri rw" "/dev/dri/renderD128 rw" ];
      ReadWritePaths = [ "/var/cache/jellyfin" ];
    };
  };
}
