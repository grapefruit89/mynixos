{ config, lib, pkgs, ... }:
let
  user = config.my.configs.identity.user;
in
{
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${user} = { pkgs, ... }: {
    home.stateVersion = "25.11";

    # Permanente Umgebungsvariablen (Token)
    home.sessionVariables = {
      GITHUB_TOKEN = "ghp_DEIN_TOKEN";
      GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_DEIN_TOKEN";
    };

    # Git-Konfiguration (ohne Warnungen)
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Moritz Baumeister";
          email = "moritz.baumeister@gmail.com";
        };
        init.defaultBranch = "main";
      };
    };

    # Der "Godmode" Alias für Vollzugriff
    programs.bash.shellAliases = {
      godmode = "gemini --yolo --include-directories /etc/nixos,/home/moritz";
    };
  };
}
