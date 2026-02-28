/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        User Identity Management
 * TRACE-ID:     NIXH-CORE-032
 * PURPOSE:      Definition der System-User & Authorized SSH Keys.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
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
