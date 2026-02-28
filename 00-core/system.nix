/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "System"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:abb42f9e07e760adc07df86a4a76379f09b99353dcab1dc4fa74ffe0a6e92c6e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
