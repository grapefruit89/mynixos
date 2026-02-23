{ config, lib, pkgs, ... }:
{
  # ── BOOTLOADER ───────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # ── SYSTEM ───────────────────────────────────────────────────────────────
  networking.hostName = "q958";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # NTP: deutsche Pool-Server
  networking.timeServers = [
    "0.de.pool.ntp.org"
    "1.de.pool.ntp.org"
    "2.de.pool.ntp.org"
    "3.de.pool.ntp.org"
  ];

  # DNS: lokal via AdGuard, Fallback verschluesselt (DoT)
  networking.nameservers = [
    "127.0.0.1"
    "1.1.1.1#one.one.one.one"
    "9.9.9.9#dns.quad9.net"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "opportunistic";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # ── PAKETE ───────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nodejs_22
    alejandra
    git
    htop
    wget
    curl
    tree
    unzip
    file
    nix-output-monitor
  ];

  programs.bash.shellAliases = {
    gemini = "npx @google/gemini-cli";
  };

  environment.sessionVariables = {
    PATH = "/home/moritz/.npm-global/bin:$PATH";
  };
}
