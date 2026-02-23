{ config, lib, pkgs, ... }:
{
  imports = [
    ./hosts/q958/hardware-configuration.nix
    ./hosts/common/core
    ./modules/00-system/nix-settings.nix
    ./modules/10-infrastructure/tailscale.nix
    ./modules/10-infrastructure/traefik.nix
    # ./modules/10-infrastructure/pocket-id.nix # Temporarily disabled due to 'option does not exist' error

    # Backend Media
    ./modules/20-backend-media/sabnzbd.nix
    # ./modules/20-backend-media/prowlarr.nix
    ./modules/30-frontend-media/audiobookshelf.nix
    ./modules/30-frontend-media/jellyfin.nix
    ./modules/40-services/vaultwarden.nix
    ./modules/40-services/homepage.nix
    ./modules/40-services/n8n.nix

    # Enabled Services
    ./modules/90-services-enabled/default.nix
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName              = "q958";
  networking.networkmanager.enable = true;

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];

  time.timeZone      = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  console.keyMap = lib.mkForce "de";

  environment.systemPackages = with pkgs; [
    git htop wget curl tree unzip file
    nix-output-monitor
  ];

  system.stateVersion = "24.11";
}