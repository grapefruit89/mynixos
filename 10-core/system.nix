/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        System
 * TRACE-ID:     NIXH-CORE-026
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:6caacc5be121ed42886e817de3d8ab58e32c0c1cc67e03096e71cda94a690521
 */

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

  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    nodejs_22 alejandra git htop wget curl tree unzip file nix-output-monitor
  ];

  environment.sessionVariables = {
    PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
  };

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
