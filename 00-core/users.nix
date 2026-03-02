/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-033
 *   title: "Users (Declarative Only)"
 *   layer: 00
 * summary: Strict declarative user management without imperative mutations.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/users-groups.nix
 * ---
 */
{ config, ... }:
let
  user = config.my.configs.identity.user;
in
{
  # ── USER DEFINITION ──────────────────────────────────────────────────────
  users.users.${user} = {
    isNormalUser = true;
    # Wheel für Sudo, Video/Render für GPU-Transcoding
    extraGroups = [ "wheel" "video" "render" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX"
    ];
  };

  # ── SRE ENFORCEMENT ──────────────────────────────────────────────────────
  # 🚀 KRITISCH: Verhindert manuelle 'useradd' oder 'passwd' Befehle.
  # Das System ist nur über den Code änderbar (Single Source of Truth).
  users.mutableUsers = false;
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
