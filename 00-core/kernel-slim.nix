# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Kernel-Schlankheitskur – Deaktiviert ungenutzte Module (Q958-spezifisch)
#   priority: P3 (Medium)
#   benefit: ~300MB RAM-Ersparnis, 3s schnellerer Boot

{ config, lib, pkgs, ... }:

let
  cfg = config.my.profiles.hardware.q958;
in
{
  # Latest Mainline Kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # Module-Blacklist (Q958 hat diese Hardware NICHT)
  boot.blacklistedKernelModules = [
    # BLUETOOTH
    "bluetooth" "btusb" "btrtl" "btbcm" "btintel" "bnep" "rfcomm"
    
    # WIFI
    "iwlwifi" "ath9k" "ath10k_core" "ath10k_pci" "rtl8192ce" "rtl8192cu" 
    "rtl8192de" "rtl8188ee" "mt76" "brcmfmac" "brcmutil"
    
    # ALTE GRAFIKTREIBER
    "nouveau" "radeon" "amdgpu" "mgag200" "ast"
    
    # EXOTISCHE HARDWARE
    "pcspkr" "iTCO_wdt" "iTCO_vendor_support"
    
    # THUNDERBOLT
    "thunderbolt"
  ];
  
  # Firmware-Optimierung
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  
  # Performance & Security
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_keepalive_time" = 600;
    "net.ipv4.tcp_keepalive_intvl" = 60;
    "net.ipv4.tcp_keepalive_probes" = 3;
  };
  
  # Initrd Optimierung
  boot.initrd.availableKernelModules = lib.mkForce [
    "ahci" "sd_mod" "xhci_pci" "usbhid" "usb_storage"
  ];
  
  # Boot-Parameter
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "logo.nologo"
  ];

  environment.systemPackages = with pkgs; [
    kmod pciutils usbutils
  ];

  assertions = [
    {
      assertion = cfg.enable == true;
      message = "kernel-slim: Hardware-Profil q958 muss aktiviert sein!";
    }
  ];
}
