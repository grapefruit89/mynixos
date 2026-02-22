{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common/core
    ../../modules/00-system/nix-settings.nix
    ../../modules/10-infrastructure/tailscale.nix
    ../../modules/10-infrastructure/traefik.nix
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName              = "q958";
  networking.networkmanager.enable = true;

  time.timeZone      = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap     = "de";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git htop wget curl tree unzip file
    nix-output-monitor sops
  ];

  system.stateVersion = "25.11";
}
