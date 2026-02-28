/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Home Manager
 * TRACE-ID:     NIXH-CORE-014
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:ba76f3ce046ff44a8a361c6cf287ff1bbfb77e179dbcbbe83bd82dc2ea0de356
 */

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
    
    # SECURITY: Secret-Environment in Shell laden
    programs.bash.initExtra = ''
      if [ -f "${envFile}" ]; then
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
