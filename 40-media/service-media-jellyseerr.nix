{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-20-SRV-036"; title = "Jellyseerr"; description = "Media requests."; layer = 30; nixpkgs.category = "services/media"; capabilities = [ "media/requests" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 2; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.jellyseerr;
  defs = config.my.defaults;
in
{
  options.my.meta.jellyseerr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.jellyseerr = { enable = lib.mkEnableOption "Jellyseerr"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/jellyseerr"; }; port = lib.mkOption { type = lib.types.port; default = 5055; }; user = lib.mkOption { type = lib.types.str; default = "jellyseerr"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "jellyseerr"; port = cfg.port; useSSO = true; description = "Jellyseerr"; netns = cfg.netns; })
    {
      services.jellyseerr = { enable = true; port = cfg.port; };
      systemd.services.jellyseerr = {
        environment.CONFIG_DIRECTORY = lib.mkForce cfg.stateDir;
        serviceConfig = { User = cfg.user; Group = cfg.group; ReadWritePaths = [ cfg.stateDir ]; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; };
      };
    }
  ]);
}
