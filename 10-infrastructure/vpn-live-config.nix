/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-019
 *   title: "Vpn Live Config"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   status: audited
 * ---
 */
{ lib, ... }:
{
  my.configs.vpn.privado = {
    publicKey = lib.mkForce "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
    endpoint = lib.mkForce "91.148.237.38:51820";
    address = lib.mkForce "100.64.3.155/32";
    dns = lib.mkForce ["198.18.0.1" "198.18.0.2"];
  };
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:68d4a25fda4f32fc7e6adee2e3a972f97b5811057c780946b43331160d3d8027
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
