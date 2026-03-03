{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-034";
    title = "Lidarr";
    description = "Music downloader and management agent with unified hardening.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/music" "automation/downloader" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.lidarr;
  defs = config.my.defaults;
in
{
  options.my.meta.lidarr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for lidarr module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "lidarr"; port = cfg.settings.server.port; useSSO = defs.security.ssoEnable; description = "Lidarr"; netns = cfg.netns; })
    {
      systemd.services.lidarr = {
        description = "Lidarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "LIDARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.lidarr}/bin/Lidarr -nobrowser -data='${cfg.stateDir}'"; ... } // factory.mkServarrHardening;
      };
    }
  ]);
}
