{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-031";
    title = "Radarr";
    description = "Movie downloader and management agent with unified hardening and ABC-tiering.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/movies" "automation/downloader" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.radarr;
  defs = config.my.defaults;
in
{
  options.my.meta.radarr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for radarr module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "radarr"; port = cfg.settings.server.port; useSSO = defs.security.ssoEnable; description = "Radarr"; netns = cfg.netns; })
    {
      systemd.services.radarr = {
        description = "Radarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "RADARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.radarr}/bin/Radarr -nobrowser -data='${cfg.stateDir}'"; ... } // factory.mkServarrHardening;
      };
    }
  ]);
}
