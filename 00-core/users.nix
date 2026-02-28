/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-033
 *   title: "Users"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, ... }:
let
  user = config.my.configs.identity.user;
in
{
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX"
    ];
  };
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:0729911546bf4617a1fae032bec822ac8814538b995a9a8025c0db6ff794e62b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
