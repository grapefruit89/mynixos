{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-20-SRV-032"; title = "Prowlarr"; description = "Indexer-manager."; layer = 30; nixpkgs.category = "services/media"; capabilities = [ "media/indexer-management" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.prowlarr;
  defs = config.my.defaults;
in
{
  options.my.meta.prowlarr = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.media.prowlarr = { enable = lib.mkEnableOption "Prowlarr"; stateDir = lib.mkOption { type = lib.types.str; default = "/var/lib/prowlarr"; }; netns = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; settings = factory.mkServarrSettingsOptions "prowlarr" 9696; environmentFiles = factory.mkServarrEnvironmentFiles "prowlarr"; };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "prowlarr"; port = cfg.settings.server.port; useSSO = true; description = "Prowlarr"; netns = cfg.netns; })
    {
      systemd.services.prowlarr = {
        description = "Prowlarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "PROWLARR" cfg.settings // { HOME = "/var/empty"; };
        serviceConfig = { Type = "simple"; DynamicUser = true; StateDirectory = "prowlarr"; ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data=/var/lib/prowlarr"; Restart = "on-failure"; } // factory.mkServarrHardening;
      };
    }
  ]);
}
