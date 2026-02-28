/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-00-SYS-CORE-033
 *   title: "Users"
 *   layer: 00
 *   req_refs: [REQ-CORE]
 *   status: stable
 * traceability:
 *   parent: NIXH-00-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:5730c06ed4da6aa9e5fd751c0db99ab94643ca82f3696402d0573629e6bb3ae5"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
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
