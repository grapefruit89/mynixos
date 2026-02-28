/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Nix Daemon Tuning
 * TRACE-ID:     NIXH-CORE-002
 * PURPOSE:      Optimierung des Nix-Builders, Binary Caches und OOM-Schutz.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:

let
  # FIX: Präzise Erkennung von wenig RAM (via Kernel-Param oder Config)
  isLowRam = (lib.any (p: lib.hasPrefix "mem=" p) config.boot.kernelParams) 
             || (config.my.configs.hardware.ramGB or 16 <= 4);
in
{
  # 📦 BINARY CACHE (Verhindert lokales Kompilieren)
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://nixhome.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # "nixhome.cachix.org-1:DEIN_PUBLIC_KEY_HIER_INSERT" # Platzhalter deaktiviert
  ];

  # 🚀 PERFORMANCE & RELIABILITY
  nix.settings.auto-optimise-store = true;
  nix.settings.builders-use-substitutes = true;
  nix.settings.fallback = true;

  # Ressourcen-Management (Intelligente Drosselung)
  nix.settings.max-jobs = if isLowRam then lib.mkForce 1 else lib.mkDefault 4;
  nix.settings.cores = if isLowRam then lib.mkForce 2 else lib.mkDefault 0; # 0 = alle Kerne
  
  nix.settings.experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
  nix.settings.sandbox = true;
  nix.settings.trusted-users = [ "root" "moritz" ];

  # 💨 CPU & IO PRIORITÄT
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # 🧹 AUTOMATISCHE REINIGUNG
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  # Assertion gegen Platzhalter-Keys
  assertions = [
    {
      assertion = !(lib.any (k: lib.hasInfix "DEIN_PUBLIC_KEY_HIER_INSERT" k) config.nix.settings.trusted-public-keys);
      message = "nix-tuning: Bitte trage einen echten Cachix-Key ein oder entferne den Platzhalter!";
    }
  ];

  # Tooling für Phase 3
  environment.systemPackages = with pkgs; [
    cachix
    nix-tree
  ];
}
