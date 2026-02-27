# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Kernel-Schlankheitskur v2.2 – Ultra-Minimal Initrd for 96MB /boot
#   priority: P3 (Medium)
#   benefit: Shrunk initrd size, faster boot, better security

{ config, lib, pkgs, ... }:

let
  cfg = config.my.profiles.hardware.q958;
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL-AUSWAHL
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # ══════════════════════════════════════════════════════════════════════════
  # MODULE-BLACKLIST
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.blacklistedKernelModules = [
    "bluetooth" "btusb" "btrtl" "btbcm" "btintel" "bnep" "rfcomm"
    "iwlwifi" "ath9k" "ath10k_core" "ath10k_pci" "rtl8192ce" "rtl8192cu"
    "rtl8192de" "rtl8188ee" "mt76" "brcmfmac" "brcmutil"
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
  # INITRD-OPTIMIERUNG (EXPERT-ONLY: Shrinking for 96MB Survival)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Disable inclusion of standard modules
  boot.initrd.includeDefaultModules = lib.mkForce false;
  
  # Manual selection of CRITICAL modules for Q958 boot
  boot.initrd.availableKernelModules = lib.mkForce [
    # Storage (Coffee Lake / SATA / NVME)
    "ahci" "sd_mod" "nvme"
    
    # Input/Bus (For emergency console)
    "xhci_pci" "usbhid" "usb_storage"
    
    # Filesystem (Ext4 is standard)
    "ext4"
  ];

  # Compress initrd with zstd (Best balance between size and speed)
  boot.initrd.compressor = "zstd";
  
  # ══════════════════════════════════════════════════════════════════════════
  # MONITORING & DEBUGGING
  # ══════════════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    perf
    kmod
    pciutils
    usbutils
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # BOOT-PARAMETER
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "logo.nologo"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # ASSERTIONS
  # ══════════════════════════════════════════════════════════════════════════
  
  assertions = [
    {
      assertion = cfg.enable == true;
      message = "kernel-slim: Hardware-Profil q958 muss aktiviert sein!";
    }
  ];
}
