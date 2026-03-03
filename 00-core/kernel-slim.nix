{ config, lib, pkgs, ... }:

let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-012";
    title = "Kernel Slim";
    description = "Optimized kernel for Q958 by blacklisting unused modules.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [ "kernel/hardening" "system/performance" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  cfg = config.my.profiles.hardware.q958;
  
  ramBenchmark = pkgs.writeShellScriptBin "ram-benchmark" ''
    #!/usr/bin/env bash
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔬 Kernel RAM-Footprint Analyse"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    TOTAL=$(free -m | awk 'NR==2 {print $2}')
    USED=$(free -m | awk 'NR==2 {print $3}')
    echo "Gesamt-RAM:   ''${TOTAL} MB"
    echo "Verwendet:    ''${USED} MB"
    MODULES=$(lsmod | wc -l)
    echo "Geladene Module: $((MODULES - 1))"
  '';
in
{
  options.my.meta.kernel_slim = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for kernel-slim module";
  };


  config = lib.mkIf (config.my.services.kernelSlim.enable && cfg.enable) {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    
    boot.blacklistedKernelModules = [
      "bluetooth" "btusb" "btrtl" "btbcm" "btintel" "bnep" "rfcomm"
      "iwlwifi" "ath9k" "ath10k_core" "ath10k_pci" "rtl8192ce" "rtl8192cu" "rtl8192de" "rtl8188ee" "mt76" "brcmfmac" "brcmutil"
      "nouveau" "radeon" "amdgpu" "mgag200" "ast"
      "pcspkr" "iTCO_wdt" "iTCO_vendor_support" "thunderbolt"
    ];
    
    hardware.enableRedistributableFirmware = lib.mkForce false;
    hardware.firmware = lib.mkForce [ pkgs.linux-firmware ];
    
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
      "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
      "net.ipv4.tcp_syncookies" = lib.mkForce 1;
      "kernel.kptr_restrict" = lib.mkForce 2;
      "kernel.dmesg_restrict" = lib.mkForce 1;
      "vm.swappiness" = 10;
      "net.ipv4.tcp_fastopen" = 3;
    };
    
    boot.initrd.availableKernelModules = lib.mkForce [ "ahci" "sd_mod" "xhci_pci" "usbhid" "usb_storage" ];
    
    environment.systemPackages = with pkgs; [ linuxPackages_latest.perf ramBenchmark kmod pciutils usbutils ];
    programs.bash.shellAliases = { ram-bench = "${ramBenchmark}/bin/ram-benchmark"; };
    
    boot.kernelParams = [ "quiet" "loglevel=3" "systemd.show_status=auto" "rd.udev.log_level=3" "logo.nologo" ];
    
    systemd.services.kernel-slim-info = {
      description = "Kernel Slim Info Banner";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = ''
        logger -t kernel-slim "Optimized kernel loaded (Q958 profile)"
        MODULES=$(lsmod | wc -l)
        logger -t kernel-slim "Loaded modules: $((MODULES - 1))"
      '';
    };
  };
}
