{ config, lib, pkgs, utils, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-030";
    title = "Sonarr";
    description = "TV series downloader and management agent with unified hardening.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/tv" "automation/downloader" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.sonarr;
  defs = config.my.defaults;
in
{
  options.my.meta.sonarr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for sonarr module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "sonarr"; port = cfg.settings.server.port; useSSO = defs.security.ssoEnable; description = "Sonarr"; netns = cfg.netns; })
    {
      systemd.services.sonarr = {
        description = "Sonarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "SONARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = utils.escapeSystemdExecArgs [ (lib.getExe cfg.package or pkgs.sonarr) "-nobrowser" "-data=${cfg.stateDir}" ]; ... } // factory.mkServarrHardening // { RestrictNamespaces = lib.mkForce false; };
      };
    }
  ]);
}
