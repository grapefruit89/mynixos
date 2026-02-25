{ config, lib, pkgs, ... }:
{
  imports = [
    ./hosts/q958/hardware-configuration.nix

    # Core
    ./00-core/principles.nix
    ./00-core/logging.nix
    ./00-core/locale.nix
    ./00-core/ports.nix
    ./00-core/host.nix
    ./00-core/secrets.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/motd.nix
    ./00-core/system.nix
    ./00-core/aliases.nix
    ./00-core/fail2ban.nix
    ./automation.nix
    # ./00-core/storage.nix

    # Infrastructure
    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik-core.nix
    # ./10-infrastructure/traefik-routes-public.nix
    ./10-infrastructure/traefik-routes-internal.nix
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/wireguard-vpn.nix
    # ./10-infrastructure/adguardhome.nix
    # ./10-infrastructure/pocket-id.nix

    # Media Stack (neues _lib.nix-basiertes System)
    ./20-services/media/default.nix
    ./20-services/media/media-stack.nix

    # Apps
    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/paperless.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix

    # Security Policy
   # ./90-policy/security-assertions.nix  ##wieder einkommentieren! 
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];

  environment.systemPackages = with pkgs; [
    git htop wget curl tree unzip file
    nix-output-monitor
  ];

  system.stateVersion = "25.11";
}
