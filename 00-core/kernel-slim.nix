# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Smart Kernel Config – WiFi Support für Portabilität
#   priority: P3 (Medium)

{ config, lib, pkgs, ... }:

{
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL-AUSWAHL
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # ══════════════════════════════════════════════════════════════════════════
  # HARDWARE SUPPORT (Claude-Empfehlung: WiFi ist Pflicht für den Stick)
  # ══════════════════════════════════════════════════════════════════════════
  
  hardware.enableAllFirmware = true;
  networking.wireless.enable = lib.mkDefault false; # Nutze i.d.R. NM oder iwd
  
  # WiFi-Treiber NICHT blacklisten (wichtig für Portabilität)
  boot.blacklistedKernelModules = [
    # Nur echte Exoten oder unnötige HW-Beschleunigung blacklisten
    "nouveau" "radeon" "amdgpu" "mgag200" "ast"
    "pcspkr" "iTCO_wdt" "iTCO_vendor_support"
    "thunderbolt"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL HARDENING & PERFORMANCE TUNING
  # ══════════════════════════════════════════════════════════════════════════
  
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
  # INITRD-OPTIMIERUNG (Portabler machen)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Wir nehmen Standardmodule wieder rein, um den Stick portabel zu machen
  boot.initrd.includeDefaultModules = lib.mkForce true;
  
  # Zusätzliche kritische WiFi-Firmware/Treiber oft in initrd nötig? 
  # Meistens reicht post-boot.
  boot.initrd.availableKernelModules = [
    "ahci" "sd_mod" "nvme" "xhci_pci" "usbhid" "usb_storage" "ext4"
  ];

  boot.initrd.compressor = "zstd";
  
  # ══════════════════════════════════════════════════════════════════════════
  # MONITORING & DEBUGGING
  # ══════════════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    pciutils usbutils iw wirelesstools
  ];
  
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "logo.nologo"
  ];
}
