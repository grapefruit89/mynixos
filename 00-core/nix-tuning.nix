{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-CORE-017";
    title = "Nix Tuning (Binary-Only Policy)";
    description = "Strict binary cache enforcement to prevent local compilation and SSD wear.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "nix/tuning" "policy/binary-only" "maintenance/auto-gc" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.nix_tuning = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    nix.settings = {
      substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      max-jobs = lib.mkForce 0; connect-timeout = 5; builders-use-substitutes = true; auto-optimise-store = true;
      narinfo-cache-negative-ttl = 0; timeout = 1800; experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      sandbox = true; trusted-users = [ "root" config.my.configs.identity.user ];
    };
    nix.daemonCPUSchedPolicy = "idle"; nix.daemonIOSchedClass = "idle";
    nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; persistent = true; };
    environment.systemPackages = with pkgs; [ cachix nix-tree nix-diff nix-output-monitor ];
  };
}
