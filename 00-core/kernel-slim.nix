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
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # ── HARDWARE-SUPPORT ──────────────────────────────────────────────────────
  boot.initrd.availableKernelModules = [
    "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"
    "r8152" "cdc_ether" "asix" "ax88179_178a"
    "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net"
  ];

  boot.kernelModules = [ "kvm-intel" "usbnet" "i915" ];

  # Support für Broadcom WLAN (via configs.nix gesteuert)
  boot.extraModulePackages = lib.optional config.my.configs.hardware.broadcomWlan 
    config.boot.kernelPackages.broadcom_sta;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # ── INTEL UHD 630 (i3-9100) — VOLLSTÄNDIGE EXHAUSTION ────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = false; # Headless Homelab: Kein Wine/Steam notwendig
    extraPackages = with pkgs; [
      intel-media-driver          # iHD: Gen 9+ (i3-9100 = Gen 9.5)
      intel-vaapi-driver          # i965: Legacy Fallback
      intel-compute-runtime       # OpenCL für KI (Ollama)
      vpl-gpu-rt                  # Intel VPL: AV1 HW-Encode (24.11+)
      libvdpau-va-gl              # VDPAU Bridge
      ocl-icd                     # OpenCL Loader
    ];
  };

  # GuC/HuC Firmware & CPU Tuning
  boot.kernelParams = [
    "i915.enable_guc=3"          # GuC + HuC submission aktiv
    "i915.enable_fbc=1"          # Frame Buffer Compression
    "i915.fastboot=1"            # Verhindert Boot-Flicker
    "intel_pstate=active"        # Maximale CPU-Kontrolle
    "ia32_emulation=0"           # Deaktivierung 32-Bit
    "random.trust_cpu=on"        # Vertraue Hardware-RNG
    "quiet" "loglevel=3" "systemd.show_status=auto"
    "rd.udev.log_level=3" "logo.nologo"
  ];

  # ── KERNEL HARDENING ──────────────────────────────────────────────────────
  boot.blacklistedKernelModules = [
    "minix" "qnx4" "qnx6" "befs" "bfs" "efs" "erofs" "hpfs" "sysv" "ufs"
    "adfs" "affs" "hfs" "hfsplus" "ext2" "ext3" "jfs" "reiserfs"
    "ax25" "rose" "netrom" "6pack" "bpqether" "scc" "yam"
    "can" "vcan" "slcan" "appletalk" "psnap" "p8022" "ipx"
    "parport" "parport_pc" "ppdev" "lp" "floppy" "gameport" "pcspkr"
    "mgag200" "ast" "radeon" "nouveau" "thunderbolt"
    "iTCO_wdt" "iTCO_vendor_support"
  ];

  # ── SYSCTL HARDENING ─────────────────────────────────────────────────────
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
    "net.ipv4.tcp_syncookies" = lib.mkForce 1;
    "kernel.kptr_restrict" = lib.mkForce 2;
    "kernel.dmesg_restrict" = lib.mkForce 1;
    "kernel.unprivileged_bpf_disabled" = lib.mkForce 1;
    "kernel.perf_event_paranoid" = lib.mkForce 3;
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    "vm.dirty_ratio" = lib.mkDefault 15;
    "vm.dirty_background_ratio" = lib.mkDefault 5;
  };

  services.haveged.enable = true;

  # ── VAINFO TOOLING ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    libva-utils     # vainfo
    intel-gpu-tools  # intel_gpu_top
    clinfo          # OpenCL Info
  ];
}



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:007ceebfc7782b370a23a49cdcc1f7548232044fba4209f7ea2d192cce8d4255
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
