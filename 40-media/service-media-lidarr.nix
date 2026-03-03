{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-20-SRV-034"; title = "Lidarr"; description = "Music downloader."; layer = 30; nixpkgs.category = "services/media"; capabilities = [ "media/music" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.lidarr;
  defs = config.my.defaults;
in
{
  options.my.meta.lidarr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.lidarr = { enable = lib.mkEnableOption "Lidarr"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/lidarr/.config/Lidarr"; }; user = lib.mkOption { type = lib.types.str; default = "lidarr"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; settings = factory.mkServarrSettingsOptions "lidarr" 8686; environmentFiles = factory.mkServarrEnvironmentFiles "lidarr"; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "lidarr"; port = cfg.settings.server.port; useSSO = true; description = "Lidarr"; netns = cfg.netns; })
    {
      systemd.services.lidarr = {
        description = "Lidarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "LIDARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.lidarr}/bin/Lidarr -nobrowser -data='${cfg.stateDir}'"; Restart = "on-failure"; ReadWritePaths = [ cfg.stateDir defs.paths.mediaRoot defs.paths.downloadsDir ]; } // factory.mkServarrHardening;
      };
    }
  ]);
}
