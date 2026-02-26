# meta:
#   owner: moritz
#   status: active
#   scope: private
#   summary: Persönliche User-Konfiguration (Home-Manager)

{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    micro
    neofetch
    htop
    ncdu
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
    };
  };

  programs.git = {
    enable = true;
    userName = "Moritz Baumeister";
    userEmail = "moritzbaumeister@gmail.com";
  };
}
