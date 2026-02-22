{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common/core
    ../../modules/10-infrastructure/tailscale.nix
    ../../modules/10-infrastructure/traefik.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "q958";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.xkb = { layout = "de"; variant = ""; };
  console.keyMap = "de";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.moritz = {
    isNormalUser = true;
    description = "Moritz Baumeister";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscodium git htop wget curl tree unzip file nix-output-monitor
    sops
  ];

  programs.firefox.enable = true;

  services.printing.enable = false;

  system.stateVersion = "25.11";
}
