/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-90-POL-001
 *   title: "No Legacy"
 *   layer: 90
 * architecture:
 *   req_refs: [REQ-POL]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:4f1a2f3f5654369294af1aec6133c12833bef137b758810c4f1a520378d26ca9
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
