{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-40-MED-015"; title = "Sabnzbd"; description = "Usenet download client."; layer = 40; nixpkgs.category = "services/media"; capabilities = [ "media/usenet" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.sabnzbd;
  defs = config.my.defaults;
in
{
  options.my.meta.sabnzbd = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.sabnzbd = { enable = lib.mkEnableOption "Sabnzbd"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/sabnzbd"; }; port = lib.mkOption { type = lib.types.port; default = 8080; }; user = lib.mkOption { type = lib.types.str; default = "sabnzbd"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "sabnzbd"; port = cfg.port; useSSO = true; description = "Sabnzbd"; netns = cfg.netns; })
    {
      services.sabnzbd = { enable = true; user = cfg.user; group = cfg.group; };
      systemd.services.sabnzbd = {
        environment.SAB_CONFIG_FILE = "${cfg.stateDir}/sabnzbd.ini";
        serviceConfig = { User = cfg.user; Group = cfg.group; ReadWritePaths = [ cfg.stateDir defs.paths.downloadsDir ]; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; };
      };
    }
  ]);
}
