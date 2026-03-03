{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-032";
    title = "Prowlarr";
    description = "Indexer-manager for all arr-apps with DynamicUser isolation and SSO support.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/indexer-management" "security/dynamic-user" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.prowlarr;
  defs = config.my.defaults;
in
{
  options.my.meta.prowlarr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for prowlarr module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "prowlarr"; port = cfg.settings.server.port; useSSO = defs.security.ssoEnable; description = "Prowlarr"; netns = cfg.netns; })
    {
      systemd.services.prowlarr = {
        description = "Prowlarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "PROWLARR" cfg.settings // { HOME = "/var/empty"; };
        serviceConfig = { Type = "simple"; DynamicUser = true; StateDirectory = "prowlarr"; ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data=/var/lib/prowlarr"; ... } // factory.mkServarrHardening;
      };
    }
  ]);
}
