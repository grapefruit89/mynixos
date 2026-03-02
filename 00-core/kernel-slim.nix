/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-012
 *   title: "Kernel Slim (Hardened Edition)"
 *   layer: 00
 * summary: Optimized kernel for Q958 with security hardening and QSV exhaustion.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # ── HARDWARE-SUPPORT (Base) ──────────────────────────────────────────────
  boot.initrd.availableKernelModules = [
    "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"
    "r8152" "cdc_ether" "asix" "ax88179_178a"
  ];

  boot.kernelModules = [ "kvm-intel" "i915" ];

  # ── INTEL UHD 630 OPTIMIERUNG ────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  # ── SRE KERNEL PARAMS (Security & Performance) ──────────────────────────
  boot.kernelParams = [
    # 🎥 GPU Tuning
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.fastboot=1"
    
    # 🔒 Security Hardening (Non-Breaking)
    "slab_nomerge"       # Verhindert Heap-Exploits durch Kernel-Object Trennung
    "page_poison=1"      # Überschreibt gelöschten RAM (Sicherheit)
    "page_alloc.shuffle=1" # Randomisiert Page-Allocation
    "debugfs=off"        # Schließt eine große Angriffsfläche (Info-Leak)
    "random.trust_cpu=on"
    
    # 🤫 Silent Boot
    "quiet" "loglevel=3" "systemd.show_status=auto"
    "rd.udev.log_level=3" "logo.nologo"
  ];

  # ── SYSCTL HARDENING ─────────────────────────────────────────────────────
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.perf_event_paranoid" = 3;
    
    # Netzwerk-Härtung (Martian Packet Detection)
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.default.log_martians" = true;
    "net.ipv4.conf.all.accept_redirects" = false;
    "net.ipv6.conf.all.accept_redirects" = false;
  };

  # ── MODULE BLACKLIST (Attack Surface Reduction) ─────────────────────────
  boot.blacklistedKernelModules = [
    "ax25" "netrom" "rose" # Veraltete Funk-Protokolle
    "minix" "sysv" "ufs"   # Antike Filesysteme
    "floppy" "lp" "parport" # Antike Hardware
  ];

  services.haveged.enable = true; # Entropie-Generator für schnellere Crypto
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
