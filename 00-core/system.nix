{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-CORE-029";
    title = "System (SRE Boot & Security)";
    description = "systemd-boot tuning for small ESP and kernel self-protection.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "system/bootloader" "kernel/hardening" "workflow/hygiene" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.system = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    boot.loader = {
      systemd-boot = { enable = true; configurationLimit = 15; editor = false; };
      efi.canTouchEfiVariables = true; grub.enable = false; timeout = 3;
    };
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 1; "net.ipv4.conf.default.rp_filter" = 1; "net.ipv4.tcp_syncookies" = 1;
      "kernel.kptr_restrict" = 2; "kernel.dmesg_restrict" = 1; "kernel.unprivileged_bpf_disabled" = 1;
    };
    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    environment.systemPackages = with pkgs; [ nodejs_22 alejandra git htop wget curl tree unzip file nix-output-monitor rsync hdparm ];
    environment.sessionVariables = { PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH"; };
    environment.etc."git-hooks/pre-commit" = { mode = "0755"; text = "#!/usr/bin/env bash\n..."; }; # Shortened
    programs.git = { enable = true; config.core.hooksPath = "/etc/git-hooks"; };
  };
}
