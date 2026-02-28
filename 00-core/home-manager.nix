/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-010
 *   title: "Home Manager"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:c80baf1c1e8f0dee4a3494d92117ba78354065e20b02a754357313d33caab349
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
