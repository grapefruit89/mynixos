{ config, lib, pkgs, ... }:
let
  msg = prefix: alt: "🚫 [LEGACY-BLOCK] ${prefix} ist veraltet (Pre-2015 Tech). Bitte nutze stattdessen ${alt}. Grund: Performance, Security und 2026-Standard.";
in
{
  # 🛡️ ACTIVE ASSERTIONS (Stoppt den Build bei Verstoß)
  assertions = [
    {
      assertion = !config.boot.loader.grub.enable;
      message = msg "GRUB Bootloader" "systemd-boot (boot.loader.systemd-boot.enable = true)";
    }
    {
      assertion = !config.services.cron.enable;
      message = msg "Cron-Jobs" "systemd.timers (deutlich besseres Logging & Abhängigkeiten)";
    }
    {
      assertion = !config.networking.networkmanager.enable;
      message = msg "NetworkManager" "systemd-networkd (schlanker, deklarativer, server-tauglich)";
    }
    {
      assertion = !config.services.xserver.enable;
      message = msg "X11 / XServer" "Headless-Betrieb (keine GUI auf dem Server-Stick)";
    }
    {
      assertion = !config.services.pulseaudio.enable;
      message = msg "PulseAudio" "PipeWire (services.pipewire.enable = true)";
    }
    {
      assertion = !config.services.nscd.enable;
      message = msg "nscd (Name Service Cache)" "systemd-resolved (services.resolved.enable = true)";
    }
  ];

  # 🛠️ AUTOMATISCHE BEREINIGUNG (Force-Disable für den Rest)
  config = {
    # Dateisystem-Altlasten im Kernel sperren
    boot.blacklistedKernelModules = [
      "ext2" "ext3" "jfs" "reiserfs" "hfs" "hfsplus" "ntfs" 
      "adfs" "affs" "befs" "bfs" "efs" "erofs" "hpfs" "sysv" "ufs"
    ];

    # Veraltete Netzwerk-Tools entfernen (iproute2 ist Pflicht)
    environment.systemPackages = with pkgs; [
      iproute2
    ];

    # Moderne Standards erzwingen
    networking.nftables.enable = true;
    networking.firewall.enable = true;
    services.resolved.enable = true;
    services.timesyncd.enable = true;

    # Protokoll-Härtung (Kein SMBv1)
    services.samba.extraConfig = "server min protocol = SMB2_10";
    
    # Initrd auf Modernität trimmen
    boot.initrd.compressor = "zstd";
  };
}
