/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-021
 *   title: "Jellyfin"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:f6d2a66fed0dd1333f7c1d58eb1f998f1d07314b5f7f181708ba509148561b80
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
