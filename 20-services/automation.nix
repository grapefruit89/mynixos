/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-018
 *   title: "Automation"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, pkgs, lib, ... }: 
let
  bastelmodus = config.my.configs.bastelmodus;
  user = config.my.configs.identity.user;
in
{
  security.sudo.extraRules = [
    {
      users = [ user ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix";
          options = [ "NOPASSWD" ];
        }
        # Im Bastelmodus alles ohne Passwort
        {
          command = "ALL";
          options = lib.mkIf bastelmodus [ "NOPASSWD" ];
        }
      ];
    }
  ];
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:2e0e5ff3a4879d771393b8379007db1e7380111d261a6462e322fe4ba0d574eb
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
