{ config, lib, pkgs, ... }: {
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
