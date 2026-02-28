/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Jellyfin
 * TRACE-ID:     NIXH-SRV-021
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:8852a628c8a6211e5b5e73290642b96fb147522e71c595c4d9f8116fda510476
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
