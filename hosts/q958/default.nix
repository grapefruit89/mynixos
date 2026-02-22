{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common/core
    ../../modules/00-system/nix-settings.nix
    ../../modules/10-infrastructure/tailscale.nix
    ../../modules/10-infrastructure/traefik.nix
    ../../modules/10-infrastructure/pocket-id.nix

    # Backend Media
    ../../modules/20-backend-media/sabnzbd.nix
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName              = "q958";
  networking.networkmanager.enable = true;

  time.timeZone      = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap     = "de";

  # ── SOUND (Pipewire – moderner Standard) ───────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  environment.systemPackages = with pkgs; [
    vscodium
    git htop wget curl tree unzip file
    nix-output-monitor sops
  ];

  environment.shellAliases = {
    sops-edit = "sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops /home/moritz/nix-config/secrets.sops.yaml'";
    sops-show = "sudo bash -c 'SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops -d /home/moritz/nix-config/secrets.sops.yaml'";
  };

  system.stateVersion = "25.11";
}
