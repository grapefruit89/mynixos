/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-023
 *   title: "_lib"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ lib, pkgs }:
{ name
, port
, stateOption
, defaultStateDir
, supportsUserGroup ? true
, defaultUser ? name
, defaultGroup ? name
, statePathSuffix ? null
}:
{ config, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  cfg = config.my.media.${name};
  common = config.my.media.defaults;
  
  nativePort = if name == "sonarr" then 8989
               else if name == "radarr" then 7878
               else if name == "prowlarr" then 9696
               else if name == "readarr" then 8787
               else if name == "sabnzbd" then 20080
               else if name == "jellyfin" then 8096
               else if name == "jellyseerr" then 5055
               else port;

  stateValue =
    if statePathSuffix == null
    then "/data/state/${name}"
    else "/data/state/${name}/${statePathSuffix}";

  serviceBase = myLib.mkService {
    inherit config;
    name = name;
    port = nativePort;
    useSSO = true;
    description = "${name} Media Service";
    netns = cfg.netns;
  };
in
{
  options.my.media.${name} = {
    enable = lib.mkEnableOption "the ${name} service";
    stateDir = lib.mkOption { type = lib.types.str; default = "/data/state/${name}"; };
    user = lib.mkOption { type = lib.types.str; default = defaultUser; };
    group = lib.mkOption { type = lib.types.str; default = defaultGroup; };
    netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = common.netns; };
    expose = {
      enable = lib.mkOption { type = lib.types.bool; default = true; };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      services.${name} = {
        enable = true;
        openFirewall = lib.mkForce false;
        ${stateOption} = stateValue;
      } // lib.optionalAttrs supportsUserGroup {
        user = cfg.user;
        group = cfg.group;
      } // lib.optionalAttrs (name == "jellyfin") {
        cacheDir = "/mnt/fast-pool/cache/jellyfin";
      };

      systemd.services.${name}.serviceConfig = {
        ProtectSystem = lib.mkForce "full";
        ReadWritePaths = [ cfg.stateDir "/mnt/media" "/mnt/media/downloads" "/mnt/fast-pool/metadata" "/mnt/fast-pool/cache" ];
        BindPaths = lib.mkIf (name == "sonarr" || name == "radarr" || name == "readarr" || name == "prowlarr") [
          "/mnt/fast-pool/metadata/${name}:/var/lib/${name}/MediaCover"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /mnt/fast-pool/metadata/${name} 0750 ${cfg.user} ${cfg.group} -"
        "d /mnt/fast-pool/cache/${name} 0750 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:b66fed74250ee048ddffe13c602917740c041d359d4d7f08e3dedefd101b91f5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
