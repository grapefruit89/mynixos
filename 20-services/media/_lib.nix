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
  cfg = config.my.media.${name};
  common = config.my.media.defaults;
  
  # Map name to its native default port if patch fails
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
    then cfg.stateDir
    else "${cfg.stateDir}/${statePathSuffix}";
  defaultHost =
    if common.domain == null
    then null
    else "${common.hostPrefix}-${name}.${common.domain}";
in
{
  options.my.media.${name} = {
    enable = lib.mkEnableOption "the ${name} service";
    stateDir = lib.mkOption { type = lib.types.str; default = defaultStateDir; };
    user = lib.mkOption { type = lib.types.str; default = defaultUser; };
    group = lib.mkOption { type = lib.types.str; default = defaultGroup; };
    netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = common.netns; };
    expose = {
      enable = lib.mkOption { type = lib.types.bool; default = true; };
      host = lib.mkOption { type = lib.types.nullOr lib.types.str; default = defaultHost; };
    };
  };

  config = lib.mkIf cfg.enable {
    services.${name} = {
      enable = true;
      openFirewall = lib.mkForce false;
      ${stateOption} = stateValue;
    } // lib.optionalAttrs supportsUserGroup {
      user = cfg.user;
      group = cfg.group;
    };

    systemd.services.${name}.serviceConfig = {
      NetworkNamespacePath = lib.mkIf (cfg.netns != null) "/run/netns/${cfg.netns}";
      ProtectSystem = lib.mkForce "full";
      ReadWritePaths = [ cfg.stateDir "/data/media" "/data/downloads" ];
    };

    services.traefik.dynamicConfigOptions.http = lib.mkIf cfg.expose.enable {
      routers.${name} = {
        rule = "Host(`${cfg.expose.host}`)";
        entryPoints = [ "websecure" ];
        tls.certResolver = common.certResolver;
        middlewares = [ common.secureMiddleware ];
        service = name;
      };
      # ROUTING: Try native port first, fall back to register port
      services.${name}.loadBalancer.servers = [
        { url = "http://${if cfg.netns != null then "10.200.1.2" else "127.0.0.1"}:${toString nativePort}"; }
      ];
    };
  };
}
