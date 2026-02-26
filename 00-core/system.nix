# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: system Modul (Basis-Konfiguration & Bootloader)

{ config, lib, pkgs, ... }:
{
  # -- BOOTLOADER -----------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 3;
    };

    kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.tcp_syncookies" = 1;
    };
  };

  # -- SYSTEM BASIS ---------------------------------------------------------
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # -- NIX EINSTELLUNGEN ----------------------------------------------------
  nix = {
    # Wir nutzen Standard-Einstellungen, um Fehler mit Cache-Keys zu vermeiden.
    # NixOS nutzt per Default den offiziellen Cache (Binary First).
    gc = {
      automatic = true;
      dates = "Sun 03:30";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  # -- PAKETE ---------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    nodejs_22 alejandra git htop wget curl tree unzip file nix-output-monitor
  ];

  environment.sessionVariables = {
    PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
  };

  # source: /etc/git-hooks/pre-commit
  environment.etc."git-hooks/pre-commit" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -uo pipefail
      empty_files=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.nix$' || true)
      if [ -n "$empty_files" ]; then
        for f in $empty_files; do
          if [ -f "$f" ] && [ ! -s "$f" ]; then
            echo "ERROR: Empty .nix file staged for commit: $f" >&2
            exit 1
          fi
        done
      fi
    '';
  };

  programs.git = {
    enable = true;
    config.core.hooksPath = "/etc/git-hooks";
  };
}
