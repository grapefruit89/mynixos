/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-018
 *   title: "Automation"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
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
 *   checksum: sha256:89c83de3f36900ddaf2fbc6d2b0974590dd69f0c132cb9d86b0f00edbaccf615
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
