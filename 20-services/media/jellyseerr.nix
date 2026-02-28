/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Jellyseerr Request Manager
 * TRACE-ID:     NIXH-SRV-011
 * PURPOSE:      Anfrage-Management für Filme und Serien.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "jellyseerr";
      port = config.my.ports.jellyseerr;
      stateOption = "configDir";
      defaultStateDir = "/var/lib/jellyseerr/config";
      supportsUserGroup = false;
    })
  ];

  users.groups.jellyseerr = { };
  users.users.jellyseerr = {
    isSystemUser = true;
    group = "jellyseerr";
  };

  systemd.services.jellyseerr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "jellyseerr";
    Group = "jellyseerr";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyseerr 0750 jellyseerr jellyseerr - -"
    "d /var/lib/jellyseerr/config 0750 jellyseerr jellyseerr - -"
    "d /var/lib/jellyseerr/config/logs 0750 jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr - jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr/config - jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr/config/logs - jellyseerr jellyseerr - -"
  ];
}
