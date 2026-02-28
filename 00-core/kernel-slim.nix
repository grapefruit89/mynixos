/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Aggressive Kernel Slimming
 * TRACE-ID:     NIXH-CORE-003
 * PURPOSE:      Reduzierung der Angriffsfläche & Boot-Beschleunigung durch Blacklisting.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [90-policy/no-legacy.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:

{
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL-AUSWAHL
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # ══════════════════════════════════════════════════════════════════════════
  # AGGRESSIVE MODULE BLACKLIST (Kein Legacy-Dreck, keine Exoten)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.blacklistedKernelModules = [
    # 💾 Uralte Dateisysteme (Über no-legacy.nix hinaus)
    "minix" "qnx4" "qnx6" "squashfs" "befs" "bfs" "efs" "erofs" "hpfs" "sysv" "ufs" "adfs" "affs"
    
    # 📻 Amateur-Radio & Exoten (Sicherheitsrisiko & Bloat)
    "ax25" "rose" "netrom" "6pack" "bpqether" "scc" "yam" "baycom_ser_fdx" "baycom_ser_hdx"
    
    # 🏭 Industrie-Busse & Exoten
    "can" "vcan" "slcan" "gw" "can-raw" "can-gw" "appletalk" "psnap" "p8022" "p8023" "ipx"
    
    # 📟 Parallele & Uralte Schnittstellen
    "parport" "parport_pc" "ppdev" "lp" "floppy"
    
    # 📠 ISDN & Analoge Modems
    "isdn" "mishid" "hisax" "avmfritz"
    
    # 🕹️ Uralte Eingabegeräte & PC-Speaker
    "gameport" "lightning" "analog" "joydump" "pcspkr"
    
    # Unbenutzte Grafiktreiber (Intel-only System)
    "nouveau" "radeon" "amdgpu" "mgag200" "ast"
    
    # Sonstiges
    "iTCO_wdt" "iTCO_vendor_support" "thunderbolt"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL HARDENING & 32-BIT DEAKTIVIERUNG
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelParams = [
    # Deaktivierung von 32-Bit Emulation (ia32_emulation=0)
    # Verhindert 32-bit Malware auf 64-bit Systemen.
    "ia32_emulation=0"
    
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "logo.nologo"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
    "net.ipv4.tcp_syncookies" = lib.mkForce 1;
    "kernel.kptr_restrict" = lib.mkForce 2;
    "kernel.dmesg_restrict" = lib.mkForce 1;
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    "net.ipv4.tcp_fastopen" = lib.mkDefault 3;
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # INITRD-OPTIMIERUNG (Der "Clean Room" Effekt)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Nur das absolut Notwendige in die initrd packen
  boot.initrd.includeDefaultModules = lib.mkForce false;
  
  boot.initrd.availableKernelModules = [
    # Moderne Storage-Treiber
    "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"
    # Dateisysteme für den Boot
    "ext4" "vfat"
  ];

  boot.initrd.compressor = "zstd";
  
  # ══════════════════════════════════════════════════════════════════════════
  # HARDWARE SUPPORT (WiFi & Firmware)
  # ══════════════════════════════════════════════════════════════════════════
  
  hardware.enableAllFirmware = true;
  networking.wireless.enable = lib.mkDefault false;
  
  # ══════════════════════════════════════════════════════════════════════════
  # TOOLING
  # ══════════════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    pciutils usbutils iw wirelesstools
  ];
}
