/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-010
 *   title: "Home Manager"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:aa2cf476d5ac31fa3924e94142bd8402e8e28dbe30fe01290f5044d54623ad93
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
