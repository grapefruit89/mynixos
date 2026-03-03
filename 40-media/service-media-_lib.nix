{ lib, pkgs, ... }:
{ name, port, stateOption, defaultStateDir, supportsUserGroup ? true, defaultUser ? name, defaultGroup ? "media", statePathSuffix ? null, useVpn ? false, extraServiceConfig ? {} }:
{ config, ... }:
let
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.${name};
  sreConfig = config.my.configs;
  srePaths = config.my.configs.paths;
  nativePort = if name == "sonarr" then 8989 else if name == "radarr" then 7878 else if name == "prowlarr" then 9696 else if name == "readarr" then 8787 else if name == "lidarr" then 8686 else if name == "sabnzbd" then 8080 else if name == "jellyfin" then 8096 else if name == "jellyseerr" then 5055 else port;
  stateValue = if statePathSuffix == null then "${srePaths.stateDir}/${name}" else "${srePaths.stateDir}/${name}/${statePathSuffix}";
  vpnConfig = lib.optionalAttrs useVpn { requires = [ "wireguard-vault.service" ]; after = [ "wireguard-vault.service" ]; serviceConfig = { NetworkNamespacePath = "/var/run/netns/media-vault"; RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ]; }; };
  serviceBase = myLib.mkService { inherit config; name = name; port = nativePort; useSSO = true; description = "${name} Service (Exhausted)"; netns = if useVpn then "media-vault" else null; };
in
{
  options.my.media.${name} = {
    enable = lib.mkEnableOption "the ${name} service";
    stateDir = lib.mkOption { type = lib.types.str; default = "${srePaths.stateDir}/${name}"; };
    user = lib.mkOption { type = lib.types.str; default = defaultUser; };
    group = lib.mkOption { type = lib.types.str; default = defaultGroup; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      services.${name} = { enable = true; openFirewall = lib.mkForce false; ${stateOption} = stateValue; } // lib.optionalAttrs supportsUserGroup { user = cfg.user; group = cfg.group; } // lib.optionalAttrs (name == "jellyfin") { cacheDir = "/mnt/fast-pool/cache/jellyfin"; };
      systemd.services.${name} = lib.mkMerge [ vpnConfig { serviceConfig = { ProtectSystem = lib.mkForce "full"; ProtectHome = true; PrivateTmp = true; NoNewPrivileges = true; MemoryMax = "${toString sreConfig.resourceLimits.maxMediaRamMB}M"; CPUWeight = 50; OOMScoreAdjust = 500; ReadWritePaths = [ cfg.stateDir srePaths.mediaLibrary "${srePaths.storagePool}/downloads" "/mnt/fast-pool/cache" "/mnt/fast-pool/metadata" ]; BindPaths = lib.mkIf (name == "sonarr" || name == "radarr" || name == "readarr" || name == "prowlarr" || name == "lidarr") [ "/mnt/fast-pool/metadata/${name}:/var/lib/${name}/MediaCover" ]; }; } extraServiceConfig ];
      services.caddy.virtualHosts."${name}.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}" = lib.mkIf (useVpn || name != "jellyfin") { extraConfig = lib.mkForce "import sso_auth\nreverse_proxy ${if useVpn then "10.200.1.2" else "127.0.0.1"}:${toString nativePort}"; };
      systemd.tmpfiles.rules = [ "d ${cfg.stateDir} 0750 ${cfg.user} media -" "d /mnt/fast-pool/metadata/${name} 0775 ${cfg.user} media -" "d /mnt/fast-pool/cache/${name} 0775 ${cfg.user} media -" ];
    }
  ]);
}
