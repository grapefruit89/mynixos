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
 *   checksum: sha256:f211671c8f70f7ef82b3552c1169d64c61715a042fba45f38bba1ff7f39dc382
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
