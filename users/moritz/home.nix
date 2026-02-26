# meta:
#   owner: moritz
#   status: active
#   scope: private
#   summary: Persönliche User-Konfiguration (Home-Manager Premium)

{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  # ── USER PAKETE ──────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    micro
    neofetch
    htop
    ncdu
    btop
    dust
  ];

  # ── PROGRAMM-EINSTELLUNGEN (PROFI-STYLE) ─────────────────────────────────
  programs.bash = {
    enable = true;
    historySize = 50000;
    historyFileSize = 100000;
    historyControl = [ "ignoredups" "ignorespace" ];
  };

  # Htop Konfiguration (Mitchellh-Style)
  programs.htop = {
    enable = true;
    settings = {
      color_scheme = 0;
      delay = 15;
      highlight_base_name = 1;
      highlight_megabytes = 1;
      highlight_threads = 1;
      show_program_path = 0;
    };
  };

  # Micro Editor Settings
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "simple";
      tabsize = 2;
      mouse = true;
    };
  };

  # Bat (cat alternative)
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      italic-text = "always";
    };
  };

  programs.git = {
    enable = true;
    userName = "Moritz Baumeister";
    userEmail = "moritzbaumeister@gmail.com";
    extraConfig = {
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
