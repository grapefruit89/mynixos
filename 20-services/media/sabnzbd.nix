/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-030
 *   title: "Sabnzbd"
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
 *   checksum: sha256:0587a46c6aa401db81f7bf86edbb3d31912ae81baf2f3662f59a70029d366339
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
