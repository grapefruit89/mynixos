/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-022
 *   title: "Jellyseerr"
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









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:573a26bcbfd230c4fb944ce7d1c6b56892a5cba13d7abcd630cb83127a3622c9
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
