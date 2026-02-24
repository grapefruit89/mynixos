{ config, lib, pkgs, ... }:
{
  # -- BOOTLOADER -----------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # -- SYSTEM BASIS ---------------------------------------------------------
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # -- PACKAGES -------------------------------------------------------------
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

  environment.sessionVariables = {
    PATH = "/home/moritz/.npm-global/bin:$PATH";
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
