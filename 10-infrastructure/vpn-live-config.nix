/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-10-NET-INFRA-019
 *   title: "Vpn Live Config"
 *   layer: 10
 *   req_refs: [REQ-INF]
 *   status: stable
 * traceability:
 *   parent: NIXH-10-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:68d4a25fda4f32fc7e6adee2e3a972f97b5811057c780946b43331160d3d8027"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
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
