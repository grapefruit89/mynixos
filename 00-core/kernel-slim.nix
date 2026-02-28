/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-012
 *   title: "Kernel Slim"
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
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL-AUSWAHL
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # ══════════════════════════════════════════════════════════════════════════
  # HARDWARE-KOMPATIBILITÄT (AUDIT-FIX)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.initrd.availableKernelModules = [
    # Moderne Storage-Treiber
    "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"
    # USB-Ethernet Fallback (Verhindert Headless-Deadlock bei fehlendem WLAN)
    "r8152" "cdc_ether" "asix" "ax88179_178a"
    # Virtuelle Maschinen (VMware, VirtualBox, KVM)
    "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net" "vmw_balloon"
  ];

  boot.kernelModules = [
    # Grafik & Display Fallbacks
    "vmwgfx" "vboxvideo" "virtio_gpu"
    # Netzwerk
    "usbnet"
  ];

  # Broadcom WLAN Support (Proprietär, aber oft notwendig für Laptops)
  boot.extraModulePackages = lib.optional config.my.configs.hardware.broadcomWlan 
    config.boot.kernelPackages.broadcom_sta;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # ══════════════════════════════════════════════════════════════════════════
  # AGGRESSIVE MODULE BLACKLIST (Kein Legacy-Dreck)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.blacklistedKernelModules = [
    "minix" "qnx4" "qnx6" "squashfs" "befs" "bfs" "efs" "erofs" "hpfs" "sysv" "ufs" "adfs" "affs"
    "ax25" "rose" "netrom" "6pack" "bpqether" "scc" "yam" "baycom_ser_fdx" "baycom_ser_hdx"
    "can" "vcan" "slcan" "gw" "can-raw" "can-gw" "appletalk" "psnap" "p8022" "p8023" "ipx"
    "parport" "parport_pc" "ppdev" "lp" "floppy"
    "isdn" "mishid" "hisax" "avmfritz"
    "gameport" "lightning" "analog" "joydump" "pcspkr"
    "mgag200" "ast"
    "iTCO_wdt" "iTCO_vendor_support" "thunderbolt"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL HARDENING & ENTROPIE
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelParams = [
    "ia32_emulation=0" # Deaktivierung 32-Bit
    "random.trust_cpu=on" # Vertraue Hardware-RNG (Verhindert Boot-Hänger bei Entropy-Mangel)
    "quiet" "loglevel=3" "systemd.show_status=auto" "rd.udev.log_level=3" "logo.nologo"
  ];

  services.haveged.enable = true; # Modern Entropy Daemon (Alternative zu rngd)

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
    "net.ipv4.tcp_syncookies" = lib.mkForce 1;
    "kernel.kptr_restrict" = lib.mkForce 2;
    "kernel.dmesg_restrict" = lib.mkForce 1;
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };
}







/**
 * ---
 * technical_integrity:
 *   checksum: sha256:2ae6085109d0738d811af010a80e2d65dafc2c17e01d8417b6affb758887aac5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
