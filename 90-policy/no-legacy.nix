/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        No Legacy
 * TRACE-ID:     NIXH-POL-001
 * REQ-REF:      REQ-POL
 * LAYER:        90
 * STATUS:       Stable
 * INTEGRITY:    SHA256:1b702ddb8e9d06a043bf34cca4693abc58a9368e9ee52dc65fad2d97b5df10de
 */

{ config, lib, pkgs, ... }:
let
  msg = prefix: alt: "🚫 [LEGACY-BLOCK] ${prefix} ist veraltet. Bitte nutze stattdessen ${alt}.";
in
{
  config = {
    assertions = [
      {
        assertion = !config.boot.loader.grub.enable;
        message = msg "GRUB Bootloader" "systemd-boot";
      }
      {
        assertion = !config.services.cron.enable;
        message = msg "Cron-Jobs" "systemd.timers";
      }
      {
        assertion = !config.networking.networkmanager.enable;
        message = msg "NetworkManager" "systemd-networkd";
      }
      {
        assertion = !config.services.xserver.enable;
        message = msg "X11 / XServer" "Headless-Betrieb";
      }
      {
        assertion = !config.services.pulseaudio.enable;
        message = msg "PulseAudio" "PipeWire";
      }
    ];

    services.samba.settings.global."server min protocol" = "SMB2_10";

    boot.blacklistedKernelModules = [
      "ext2" "ext3" "jfs" "reiserfs" "hfs" "hfsplus" "ntfs" 
      "adfs" "affs" "befs" "bfs" "efs" "erofs" "hpfs" "sysv" "ufs"
    ];

    environment.systemPackages = with pkgs; [ iproute2 ];

    networking.nftables.enable = true;
    networking.firewall.enable = lib.mkForce true;
    services.resolved.enable = true;
    services.timesyncd.enable = true;
    boot.initrd.compressor = "zstd";
  };
}
