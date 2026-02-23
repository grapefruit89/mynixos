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
}
