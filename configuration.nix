{ config, lib, pkgs, ... }:
{
  imports = [
    ./hosts/q958/hardware-configuration.nix
    ./00-core/ports.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/system.nix
    # ./00-core/storage.nix

    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik-core.nix
    ./10-infrastructure/traefik-routes-public.nix
    ./10-infrastructure/traefik-routes-internal.nix
    ./10-infrastructure/homepage.nix
    # ./10-infrastructure/adguardhome.nix
    # ./10-infrastructure/pocket-id.nix # Temporarily disabled due to 'option does not exist' error
    # ./10-infrastructure/wireguard-vpn.nix

    # Backend Media
    ./20-services/media-stack.nix
    ./20-services/backend-media/sabnzbd.nix
    # ./20-services/backend-media/prowlarr.nix

    # Frontend Media
    ./20-services/frontend-media/audiobookshelf.nix
    ./20-services/media/jellyfin.nix

    # Apps / Services
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/n8n.nix
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
