/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-033
 *   title: "Users"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
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
 *   checksum: sha256:5730c06ed4da6aa9e5fd751c0db99ab94643ca82f3696402d0573629e6bb3ae5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
