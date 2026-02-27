{ config, lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "bluetooth" "btusb" "joydev" "thunderbolt" ];
  zramSwap.enable = true;
  boot.kernelParams = [ "quiet" "loglevel=3" "mitigations=off" ];
}
