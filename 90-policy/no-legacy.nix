{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-90-POL-001";
    title = "No Legacy";
    description = "Blocks legacy services and insecure protocols to ensure a modern, hardened system.";
    layer = 90;
    nixpkgs.category = "system/policy";
    capabilities = [ "policy/enforcement" "security/hardening" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  msg = prefix: alt: "🚫 [LEGACY-BLOCK] ${prefix} ist veraltet. Nutze ${alt}.";
in
{
  options.my.meta.no_legacy = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for no-legacy module";
  };

  config = {
    assertions = [
      { assertion = !config.boot.loader.grub.enable; message = msg "GRUB" "systemd-boot"; }
      { assertion = !config.services.cron.enable; message = msg "Cron" "systemd.timers"; }
      { assertion = !config.networking.networkmanager.enable; message = msg "NetworkManager" "systemd-networkd"; }
    ];
    services.samba.settings.global."server min protocol" = "SMB2_10";
    boot.blacklistedKernelModules = [ "ext2" "ext3" "jfs" "reiserfs" "hfs" "hfsplus" "ntfs" ];
    networking.nftables.enable = true;
    networking.firewall.enable = lib.mkForce true;
    boot.initrd.compressor = "zstd";
  };
}
