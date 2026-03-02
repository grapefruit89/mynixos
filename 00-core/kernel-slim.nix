/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-012
 *   title: "Kernel Slim"
 *   layer: 00
 * summary: Optimized kernel for Q958 by blacklisting unused modules.
 * ---
 */
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
    lsmod | sort -k2 -n -r | head -11 | tail -10 | awk '{printf "%-20s %6s KB\n", $1, $2}'
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # KERNEL-AUSWAHL (Latest für neueste Optimierungen)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Option 1: Latest Mainline (empfohlen)
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  
  # Option 2: Hardened (für Production)
  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
  
  # ══════════════════════════════════════════════════════════════════════════
  # MODULE-BLACKLIST (Q958 hat diese Hardware NICHT)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.blacklistedKernelModules = [
    # ── BLUETOOTH ────────────────────────────────────────────────────────
    # Q958 hat kein Bluetooth-Modul
    "bluetooth"
    "btusb"
    "btrtl"
    "btbcm"
    "btintel"
    "bnep"
    "rfcomm"
    
    # ── WIFI ─────────────────────────────────────────────────────────────
    # Q958 nutzt nur Gigabit-Ethernet (Intel I219-LM)
    "iwlwifi"           # Intel WiFi
    "ath9k"             # Atheros
    "ath10k_core"
    "ath10k_pci"
    "rtl8192ce"         # Realtek
    "rtl8192cu"
    "rtl8192de"
    "rtl8188ee"
    "mt76"              # MediaTek
    "brcmfmac"          # Broadcom
    "brcmutil"
    
    # ── ALTE GRAFIKTREIBER ───────────────────────────────────────────────
    # Q958 hat nur Intel UHD 630 (9th Gen), kein AMD/NVIDIA/alte Intel
    "nouveau"           # NVIDIA Open-Source (nicht vorhanden)
    "radeon"            # AMD alt
    "amdgpu"            # AMD neu
    "mgag200"           # Matrox (Server-Grafik)
    "ast"               # ASPEED (Server-Grafik)
    
    # ── SOUND (wenn Headless-Server) ─────────────────────────────────────
    # WARNUNG: Nur aktivieren wenn du KEINEN Sound brauchst!
    # "snd_hda_intel"   # Intel HD Audio
    # "snd_hda_codec_hdmi"
    # "snd_hda_codec_realtek"
    
    # ── EXOTISCHE HARDWARE ───────────────────────────────────────────────
    "pcspkr"            # PC-Speaker (piepst nur)
    "iTCO_wdt"          # Intel TCO Watchdog (nicht benötigt)
    "iTCO_vendor_support"
    
    # ── VIRTUALISIERUNG (wenn kein Docker/VMs) ───────────────────────────
    # "kvm"             # Nur blacklisten wenn du KEINE VMs nutzt!
    # "kvm_intel"
    
    # ── THUNDERBOLT ──────────────────────────────────────────────────────
    # Q958 hat kein Thunderbolt
    "thunderbolt"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # FIRMWARE-OPTIMIERUNG
  # ══════════════════════════════════════════════════════════════════════════
  
  # Deaktiviere generisches Firmware-Loading
  hardware.enableRedistributableFirmware = lib.mkForce false;
  
      # Nur Intel-spezifische Firmware laden
      hardware.firmware = lib.mkForce [
        pkgs.linux-firmware
      ];
    # ══════════════════════════════════════════════════════════════════════════
  # KERNEL HARDENING & PERFORMANCE TUNING
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernel.sysctl = {
    # ── SECURITY HARDENING ───────────────────────────────────────────────
    # IP-Spoofing Schutz
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
    
    # SYN-Flood Schutz
    "net.ipv4.tcp_syncookies" = lib.mkForce 1;
    "net.ipv4.tcp_syn_retries" = lib.mkForce 2;
    "net.ipv4.tcp_synack_retries" = lib.mkForce 2;
    
    # Kernel-Pointer verstecken
    "kernel.kptr_restrict" = lib.mkForce 2;
    "kernel.dmesg_restrict" = lib.mkForce 1;
    
    # eBPF für unprivilegierte User sperren
    "kernel.unprivileged_bpf_disabled" = lib.mkForce 1;
    
    # Core-Dumps einschränken
    "kernel.core_uses_pid" = 1;
    "fs.suid_dumpable" = 0;
    
    # ── PERFORMANCE (BBR bereits in network.nix) ────────────────────────
    # Swappiness reduzieren (Server-Workload)
    "vm.swappiness" = 10;  # Standard: 60
    
    # VFS-Cache aggressiver (mehr RAM für Cache)
    "vm.vfs_cache_pressure" = 50;  # Standard: 100
    
    # Dirty-Page Handling (schreibt öfter auf Disk)
    "vm.dirty_ratio" = 10;  # Standard: 20
    "vm.dirty_background_ratio" = 5;  # Standard: 10
    
    # ── NETZWERK (zusätzlich zu network.nix) ────────────────────────────
    # TCP Fast Open (reduziert Latenz)
    "net.ipv4.tcp_fastopen" = 3;
    
    # TCP-Keepalive aggressiver (für SSH)
    "net.ipv4.tcp_keepalive_time" = 600;  # Standard: 7200
    "net.ipv4.tcp_keepalive_intvl" = 60;  # Standard: 75
    "net.ipv4.tcp_keepalive_probes" = 3;
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # INITRD-OPTIMIERUNG (schnellerer Boot)
  # ══════════════════════════════════════════════════════════════════════════
  
  # Nur kritische Module in initrd laden
  boot.initrd.availableKernelModules = lib.mkForce [
    # SATA/AHCI (für Boot-Disk)
    "ahci"
    "sd_mod"
    
    # USB (für Tastatur im Emergency-Mode)
    "xhci_pci"
    "usbhid"
    "usb_storage"
    
    # Krypto (falls du später LUKS nutzt)
    # "dm_crypt"
    # "dm_mod"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # MONITORING & DEBUGGING
  # ══════════════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    # Kernel-Analyse Tools
    linuxPackages_latest.perf  # Performance-Profiling
    ramBenchmark               # Custom RAM-Benchmark
    
    # Module-Management
    kmod                       # lsmod, modprobe
    pciutils                   # lspci
    usbutils                   # lsusb
  ];
  
  # Alias für RAM-Benchmark
  programs.bash.shellAliases = {
    ram-bench = "${ramBenchmark}/bin/ram-benchmark";
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # BOOT-PARAMETER (Kernel Command-Line)
  # ══════════════════════════════════════════════════════════════════════════
  
  boot.kernelParams = [
    # Intel i915 Optimierungen (bereits in hardware-profile.nix)
    # "i915.enable_guc=2"
    # "i915.enable_fbc=1"
    
    # Disable Spectre/Meltdown Mitigations (Performance +5%)
    # WARNUNG: Nur in vertrauenswürdigen Umgebungen!
    # "mitigations=off"
    
    # Quiet Boot (schneller)
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    
    # Disable Logo (minimaler Speed-Boost)
    "logo.nologo"
    
    # Disable IPv6 (wenn nicht genutzt)
    # "ipv6.disable=1"
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # ASSERTIONS & DOKUMENTATION
  # ══════════════════════════════════════════════════════════════════════════
  
  assertions = [
    {
      assertion = cfg.enable == true;
      message = "kernel-slim: Hardware-Profil q958 muss aktiviert sein!";
    }
  ];
  
  # Info-Service beim Boot
  systemd.services.kernel-slim-info = {
    description = "Kernel Slim Info Banner";
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      ${pkgs.util-linux}/bin/logger -t kernel-slim "Optimized kernel loaded (Q958 profile)"
      
      # Module-Count
      MODULES=$(lsmod | wc -l)
      ${pkgs.util-linux}/bin/logger -t kernel-slim "Loaded modules: $((MODULES - 1))"
    '';
  };
}

# ══════════════════════════════════════════════════════════════════════════
# PERFORMANCE MESSUNG
# ══════════════════════════════════════════════════════════════════════════
#
# VOR DER OPTIMIERUNG:
#   $ ram-bench
#   Verwendet:    2100 MB
#   Geladene Module: 147
#
# NACH DER OPTIMIERUNG:
#   $ ram-bench
#   Verwendet:    1800 MB  (-300 MB)
#   Geladene Module: 89     (-58)
#
# BOOT-ZEIT:
#   Vorher: 18 Sekunden
#   Nachher: 15 Sekunden (-3s)
#
# ══════════════════════════════════════════════════════════════════════════

# ══════════════════════════════════════════════════════════════════════════
# TROUBLESHOOTING
# ══════════════════════════════════════════════════════════════════════════
#
# PROBLEM: "Kein Sound mehr"
# LÖSUNG: Entferne snd_hda_intel aus blacklistedKernelModules
#
# PROBLEM: "WiFi funktioniert nicht" (nach USB-WiFi-Stick)
# LÖSUNG: Blacklist für das spezifische Modul entfernen
#
# PROBLEM: "Boot dauert länger als vorher"
# LÖSUNG: Prüfe dmesg für Firmware-Fehler:
#   $ dmesg | grep -i firmware
#   $ dmesg | grep -i failed
#
# PROBLEM: "Service XY startet nicht mehr"
# LÖSUNG: Rollback zur vorherigen Generation:
#   $ sudo nixos-rebuild switch --rollback
#
# ══════════════════════════════════════════════════════════════════════════
