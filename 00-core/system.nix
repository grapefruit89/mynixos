/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-029
 *   title: "System (SRE Boot & Security)"
 *   layer: 00
 * summary: systemd-boot tuning for small ESP and kernel self-protection.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  # ── BOOTLOADER TUNING (Aviation Grade) ───────────────────────────────────
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # 🚀 KRITISCH: Schützt die 1000MB Boot-Partition vor Überlauf
        configurationLimit = 15;
        # 🔒 SECURITY: Verhindert Manipulation der Kernel-Parameter am Boot-Prompt
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 3;
    };

    # ── KERNEL SELF PROTECTION (SRE Standard) ──────────────────────────────
    kernel.sysctl = {
      # Netzwerk-Härtung
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      
      # System-Härtung (ASLR & Info-Leak Protection)
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.perf_event_paranoid" = 3;
    };
  };

  # ── SYSTEM BASIS ─────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    nodejs_22 alejandra git htop wget curl tree unzip file nix-output-monitor
  ];

  environment.sessionVariables = {
    PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
  };

  # ── GIT HYGIENE (SRE Enforcement) ────────────────────────────────────────
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
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
