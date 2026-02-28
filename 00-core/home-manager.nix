/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Home Manager Integration
 * TRACE-ID:     NIXH-CORE-021
 * PURPOSE:      User-spezifische Dotfile-Verwaltung & Secret-Injektion in Shell.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/secrets.nix]
 * LAYER:        00-core
 * STATUS:       Stable
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
