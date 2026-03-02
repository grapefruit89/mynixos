/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-022
 *   title: "Jellyseerr (SRE Exhausted)"
 *   layer: 20
 * summary: Request management for Jellyfin with standardized media paths.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/jellyseerr.nix
 * ---
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
      extraServiceConfig = {
        serviceConfig = {
          MemoryMax = "1G";
          OOMScoreAdjust = 800;
        };
      };
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
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
