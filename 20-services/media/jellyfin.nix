/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "Jellyfin"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:c2b8e2e9c2475ab380d8eca3b9816557fb30a6969282a290d8fb4cb5f6f0ad15
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
