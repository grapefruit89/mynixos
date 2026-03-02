/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-017
 *   title: "Nix Tuning (Binary-Only Policy)"
 *   layer: 00
 * summary: Strict binary cache enforcement to prevent local compilation and SSD wear.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/nix-remote-build.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  ramGB = config.my.configs.hardware.ramGB;
  isLowRam = ramGB <= 4;
  isMidRam = ramGB > 4 && ramGB <= 8;
in
{
  # ── BINARY CACHES (SSoT) ──────────────────────────────────────────────────
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # ── ⛔ NO-LOCAL-BUILD ENFORCEMENT (Aviation Grade) ──────────────────────
  nix.settings = {
    # Absolutes Verbot für lokale Builds (0 Slots)
    max-jobs = lib.mkForce 0;
    
    # Schnelle Erkennung von Netzwerkproblemen
    connect-timeout = 5;
    
    # Erlaubt dem Builder, Substitutes zu nutzen (Standard in NixOS)
    builders-use-substitutes = true;
    
    # Optimierungen
    auto-optimise-store = true;
    narinfo-cache-negative-ttl = 0; # Sofortige Cache-Revalidierung
  };

  # ── RESSOURCEN-SCHUTZ ────────────────────────────────────────────────────


  # Build-Timeout als letzte Rettung
  nix.settings.timeout = 1800;  # 30min Max (SRE: Alles über 30m ist vermutlich ein massiver Build -> Abbrechen)

  nix.settings.experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
  nix.settings.sandbox = true;
  nix.settings.trusted-users = [ "root" config.my.configs.identity.user ];

  # CPU & IO Priorität (Nix soll das System nicht blockieren)
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # ── AUTOMATISCHE PFLEGE (GC) ─────────────────────────────────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  # ── TOOLING ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cachix nix-tree nix-diff nix-output-monitor
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
