/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "Vpn Live Config"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:393ecc543218610afc8f67019d6e6b22b8ba56e10fc8a8320228895b30030c71
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
