{ config, lib, pkgs, ... }:
let
  user = config.my.configs.identity.user;
  envFile = config.my.secrets.files.sharedEnv;
in
{
  imports = [ <home-manager/nixos> ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.${user} = { ... }: {
    imports = [ (./.. + "/users/${user}/home.nix") ];
    
    # SECURITY: Do not use home.sessionVariables for secrets (store leak)
    # Instead, source the SOPS rendered environment file in bash
    programs.bash.initExtra = ''
      if [ -f "${envFile}" ]; then
        # Export all variables from the SOPS env file
        set -a
        source "${envFile}"
        set +a
      fi
    '';

    programs.bash.shellAliases = {
      godmode = "gemini --yolo --include-directories /etc/nixos,/home/moritz";
    };
  };
}
