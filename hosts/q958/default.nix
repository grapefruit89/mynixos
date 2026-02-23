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
    # ../../modules/20-backend-media/sabnzbd.nix
    # ../../modules/20-backend-media/prowlarr.nix
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName              = "q958";
  networking.networkmanager.enable = true;

  # Erstellt eine 4GB Swap-Datei, um den Arbeitsspeicher bei Bedarf zu erweitern.
  # Dies ist nützlich, um "Out of Memory"-Fehler bei speicherintensiven
  # Build-Prozessen (wie bei Sonarr/Radarr) zu verhindern.
  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];

  time.timeZone      = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  # Deutsche Tastaturkonfiguration fuer Konsole und X-Server
  console.keyMap = "de-latin1";
  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      model = "pc105";
    };
  };

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
