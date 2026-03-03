{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-20-SRV-031"; title = "Radarr"; description = "Movie downloader."; layer = 30; nixpkgs.category = "services/media"; capabilities = [ "media/movies" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.radarr;
  defs = config.my.defaults;
in
{
  options.my.meta.radarr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.radarr = { enable = lib.mkEnableOption "Radarr"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/radarr/.config/Radarr"; }; user = lib.mkOption { type = lib.types.str; default = "radarr"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; settings = factory.mkServarrSettingsOptions "radarr" 7878; environmentFiles = factory.mkServarrEnvironmentFiles "radarr"; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "radarr"; port = cfg.settings.server.port; useSSO = true; description = "Radarr"; netns = cfg.netns; })
    {
      systemd.services.radarr = {
        description = "Radarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "RADARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.radarr}/bin/Radarr -nobrowser -data='${cfg.stateDir}'"; Restart = "on-failure"; ReadWritePaths = [ cfg.stateDir defs.paths.mediaRoot defs.paths.downloadsDir ]; } // factory.mkServarrHardening;
      };
    }
  ]);
}
