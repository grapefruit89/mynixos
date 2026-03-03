{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-40-MED-013"; title = "Readarr"; description = "Book management."; layer = 40; nixpkgs.category = "services/media"; capabilities = [ "media/books" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.readarr;
  defs = config.my.defaults;
in
{
  options.my.meta.readarr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.readarr = { enable = lib.mkEnableOption "Readarr"; stateDir = lib.mkOption { type = lib.types.str; default = "${defs.paths.statePrefix}/readarr"; }; user = lib.mkOption { type = lib.types.str; default = "readarr"; }; group = lib.mkOption { type = lib.types.str; default = "media"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; settings = factory.mkServarrSettingsOptions "readarr" 8787; environmentFiles = factory.mkServarrEnvironmentFiles "readarr"; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "readarr"; port = cfg.settings.server.port; useSSO = true; description = "Readarr"; netns = cfg.netns; })
    {
      systemd.services.readarr = {
        description = "Readarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "READARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.readarr}/bin/Readarr -nobrowser -data='${cfg.stateDir}'"; Restart = "on-failure"; ReadWritePaths = [ cfg.stateDir defs.paths.mediaRoot defs.paths.downloadsDir ]; } // factory.mkServarrHardening;
      };
    }
  ]);
}
