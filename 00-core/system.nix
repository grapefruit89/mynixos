# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: system Modul

{ config, lib, pkgs, ... }:
{
  # -- BOOTLOADER -----------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # -- SYSTEM BASIS ---------------------------------------------------------
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # -- NIX EINSTELLUNGEN ----------------------------------------------------
  nix = {
    settings = {
      # Store-Optimierung: Hardlinks statt Kopien (spart ~30% NVMe-Platz)
      auto-optimise-store = true;

      # Parallele Jobs: 4 Cores, aber 1 für System lassen
      max-jobs = 3;
      cores = 4;

      # Binary Caches (schnellere Builds)
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCSeBw="
      ];

      # Flake-Features (auch ohne Flakes nützlich)
      experimental-features = [ "nix-command" "flakes" ];

      # Kein automatisches Garbage-Collect während Builds
      keep-outputs = true;
      keep-derivations = true;
    };

    # Automatische GC: wöchentlich, 14 Tage Retention
    gc = {
      automatic = true;
      dates = "Sun 03:30";      # Sonntag Nacht — HDDs können schlafen
      options = "--delete-older-than 14d";
    };

    # Store-Optimierung nach GC
    optimise = {
      automatic = true;
      dates = [ "Sun 04:00" ];  # Nach GC
    };
  };

  # -- PAKETE ---------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    nodejs_22
    alejandra
    git
    htop
    wget
    curl
    tree
    unzip
    file
    nix-output-monitor
  ];

   # source-id: CFG.identity.user
  environment.sessionVariables = {
    PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
  };

  # source: /etc/git-hooks/pre-commit (managed by NixOS)
  # sink:   git core.hooksPath -> enforced for all local repositories on this host
  environment.etc."git-hooks/pre-commit" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Block commits with empty Nix files (accidental truncation guardrail).
      empty_files=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.nix$' | while read -r f; do
        [ -f "$f" ] || continue
        if [ ! -s "$f" ]; then
          echo "$f"
        fi
      done)

      if [ -n "''${empty_files:-}" ]; then
        echo "ERROR: Empty .nix files staged for commit:" >&2
        echo "$empty_files" >&2
        echo "Abort commit. Restore/fix files first." >&2
        exit 1
      fi
    '';
  };

  programs.git = {
    enable = true;
    config = {
      core.hooksPath = "/etc/git-hooks";
    };
  };
}
