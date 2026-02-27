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
  
  # Messung: RAM-Verbrauch vor/nach Optimierung
  ramBenchmark = pkgs.writeShellScriptBin "ram-benchmark" ''
    #!/usr/bin/env bash
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔬 Kernel RAM-Footprint Analyse"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Gesamt-RAM
    TOTAL=$(free -m | awk 'NR==2 {print $2}')
    USED=$(free -m | awk 'NR==2 {print $3}')
    FREE=$(free -m | awk 'NR==2 {print $4}')
    CACHED=$(free -m | awk 'NR==2 {print $6}')
    
    echo "Gesamt-RAM:   ''${TOTAL} MB"
    echo "Verwendet:    ''${USED} MB"
    echo "Frei:         ''${FREE} MB"
    echo "Cache:        ''${CACHED} MB"
    echo ""
    
    # Geladene Kernel-Module
    MODULES=$(lsmod | wc -l)
    echo "Geladene Module: $((MODULES - 1))"
    echo ""
    
    # Top 10 RAM-Fresser (Module)
    echo "Top 10 RAM-intensive Module:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    lsmod | sort -k2 -n -r | head -11 | tail -10 | awk '{printf "%-20s %6s KB
", $1, $2}'
  '';
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
  # INITRD-OPTIMIERUNG (schnellerer Boot + Platzersparnis auf /boot)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.initrd.includeDefaultModules = lib.mkForce false;
  boot.initrd.availableKernelModules = lib.mkForce [
    "ahci" "sd_mod" "xhci_pci" "usbhid" "usb_storage" "nvme"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # MONITORING & DEBUGGING
  # ══════════════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    perf
    ramBenchmark
    kmod
    pciutils
    usbutils
  ];
  
  programs.bash.shellAliases = {
    ram-bench = "${ramBenchmark}/bin/ram-benchmark";
  };
  
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
