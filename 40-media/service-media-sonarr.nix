{ config, lib, pkgs, utils, ... }:
let
  nms = { id = "NIXH-20-SRV-030"; title = "Sonarr"; description = "TV series downloader."; layer = 30; nixpkgs.category = "services/media"; capabilities = [ "media/tv" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.sonarr;
  defs = config.my.defaults;
in
{
  options.my.meta.sonarr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.sonarr = { enable = lib.mkEnableOption "Sonarr"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/sonarr/.config/NzbDrone"; }; user = lib.mkOption { type = lib.types.str; default = "sonarr"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; settings = factory.mkServarrSettingsOptions "sonarr" 8989; environmentFiles = factory.mkServarrEnvironmentFiles "sonarr"; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "sonarr"; port = cfg.settings.server.port; useSSO = true; description = "Sonarr"; netns = cfg.netns; })
    {
      systemd.services.sonarr = {
        description = "Sonarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "SONARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = utils.escapeSystemdExecArgs [ (lib.getExe pkgs.sonarr) "-nobrowser" "-data=${cfg.stateDir}" ]; Restart = "on-failure"; ReadWritePaths = [ cfg.stateDir defs.paths.mediaRoot defs.paths.downloadsDir ]; } // factory.mkServarrHardening // { RestrictNamespaces = lib.mkForce false; };
      };
    }
  ]);
}
