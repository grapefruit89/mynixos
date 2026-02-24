{ config, lib, pkgs, ... }:
{
  # -- BOOTLOADER -----------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # -- SYSTEM BASIS ---------------------------------------------------------
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # -- PACKAGES -------------------------------------------------------------
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

  environment.sessionVariables = {
    PATH = "/home/moritz/.npm-global/bin:$PATH";
  };
}
