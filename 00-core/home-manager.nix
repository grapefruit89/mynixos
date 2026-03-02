/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-010
 *   title: "Home Manager (SRE Profile)"
 *   layer: 00
 * summary: User-environment management with secure shell-secret loading.
 * ---
 */
{ config, lib, pkgs, inputs, ... }:
let
  # sink: CFG.identity.user
  user = config.my.configs.identity.user;
  # sink: my.secrets.files.sharedEnv
  envFile = config.my.secrets.files.sharedEnv;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    
    users.${user} = { ... }: {
      imports = [ (./user-${user}-home.nix) ];
      
      # ── SHELL HARDENING ──────────────────────────────────────────────────
      # Lädt Geheimnisse aus dem RAM-Template sicher in die interaktive Shell.
      programs.bash.initExtra = ''
        if [ -f "${envFile}" ]; then
          set -a
          source "${envFile}"
          set +a
        fi
      '';

      programs.bash.shellAliases = {
        # SRE Shortcut für volle Power
        godmode = "gemini --yolo --include-directories /etc/nixos,/home/moritz";
      };
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
