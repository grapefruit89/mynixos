{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-035";
    title = "System (SRE Boot & Security)";
    description = "systemd-boot tuning for small ESP, kernel self-protection and lean system packages.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/bootloader" "kernel/hardening" "workflow/hygiene"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };
in {
  options.my.meta.system = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 3;
    };

    # 🛡️ KERNEL SELF-PROTECTION
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    # 🧹 LEAN SYSTEM (No local help pages to save SSD space)
    documentation.nixos.enable = false;

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
      rsync
      hdparm
      pciutils
      usbutils
    ];

    environment.sessionVariables = {
      PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
    };

    # 💎 SRE HYGIENE: Pre-commit hooks for Nix formatting
    programs.git = {
      enable = true;
      config = {
        core.hooksPath = "/etc/git-hooks";
        init.defaultBranch = "main";
      };
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:8d238aa01e08c70691276c537fd471de00f7c13849ecd259388df5b51b3405a6
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

