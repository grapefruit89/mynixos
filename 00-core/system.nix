# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: system Modul

{ config, lib, pkgs, ... }:
{
  # -- BOOTLOADER -----------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 3;  # Boot-Timeout von 5s auf 3s reduzieren
    };
    
    # Kernel-Parameter für bessere Intel-GPU-Performance (GuC/HuC Firmware)
    kernelParams = [
      "i915.enable_guc=2"
    ];
    
    # Kernel-Module explizit laden
    kernelModules = [ "i915" ];

    # Kernel-Sysctl-Härtung
    kernel.sysctl = {
      # Netzwerk-Härtung
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      
      # Kernel-Pointer-Protection
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      
      # SYN-Flood-Schutz
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_syn_retries" = 2;
      "net.ipv4.tcp_synack_retries" = 2;
      "net.ipv4.tcp_max_syn_backlog" = 4096;
    };
  };

  # -- SYSTEM BASIS ---------------------------------------------------------
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # -- NIX EINSTELLUNGEN ----------------------------------------------------
  nix = {
    settings = {
      auto-optimise-store = true;
      max-jobs = 4; # Voll ausnutzen (i3-9100)
      cores = 4;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCSeBw="
      ];

      # Feature-Flags
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "Sun 03:30";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      dates = [ "Sun 04:00" ];
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
  environment.etc."git-hooks/pre-commit" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

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
