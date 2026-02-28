/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-030
 *   title: "Sabnzbd"
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:65dd68254e51317fe67a4f27657bbe6ad215c18e2dea041da1034eeecb1746fc
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
