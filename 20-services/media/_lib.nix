/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-023
 *   title: "_lib (SRE Exhausted)"
 *   layer: 20
 * summary: Advanced media service helper with VPN Confinement, Resource Guarding and Declarative Config.
 * ---
 */
{ lib, pkgs }:
{ name
, port
, stateOption
, defaultStateDir
, supportsUserGroup ? true
, defaultUser ? name
, defaultGroup ? "media"
, statePathSuffix ? null
, useVpn ? false
, extraServiceConfig ? {}
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

  # ── VPN CONFINEMENT LOGIK (Nixarr Style) ──────────────────────────────────
  vpnConfig = lib.optionalAttrs useVpn {
    requires = [ "wireguard-vault.service" ];
    after = [ "wireguard-vault.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/media-vault";
      RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
    };
  };

  serviceBase = myLib.mkService {
    inherit config;
    name = name;
    port = nativePort;
    useSSO = true;
    description = "${name} Media Service";
    netns = if useVpn then "media-vault" else null;
  };
in
{
  options.my.media.${name} = {
    enable = lib.mkEnableOption "the ${name} service";
    stateDir = lib.mkOption { type = lib.types.str; default = "/data/state/${name}"; };
    user = lib.mkOption { type = lib.types.str; default = defaultUser; };
    group = lib.mkOption { type = lib.types.str; default = defaultGroup; };
    netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = common.netns; };
    expose.enable = lib.mkOption { type = lib.types.bool; default = true; };
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

      systemd.services.${name} = lib.mkMerge [
        vpnConfig
        {
          # 🛡️ SRE HARDENING (Aviation Grade)
          serviceConfig = {
            ProtectSystem = lib.mkForce "full";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
            # Resource Limits
            MemoryMax = "2G";
            CPUWeight = 50;
            OOMScoreAdjust = 500; # Media services are restartable, not ultra-critical
            
            ReadWritePaths = [ 
              cfg.stateDir 
              "/mnt/media" 
              "/mnt/fast-pool/downloads" 
              "/mnt/fast-pool/metadata" 
              "/mnt/fast-pool/cache" 
            ];
            BindPaths = lib.mkIf (name == "sonarr" || name == "radarr" || name == "readarr" || name == "prowlarr") [
              "/mnt/fast-pool/metadata/${name}:/var/lib/${name}/MediaCover"
            ];
          };
        }
        extraServiceConfig
      ];

      # Caddy Reverse Proxy (Namespace Aware)
      services.caddy.virtualHosts."${name}.${config.my.configs.identity.domain}" = lib.mkIf useVpn {
        extraConfig = lib.mkForce ''
          import sso_auth
          reverse_proxy 10.200.1.2:${toString nativePort}
        '';
      };

      systemd.tmpfiles.rules = [
        "d /mnt/fast-pool/metadata/${name} 0775 ${cfg.user} media -"
        "d /mnt/fast-pool/cache/${name} 0775 ${cfg.user} media -"
      ];
    }
  ]);
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
