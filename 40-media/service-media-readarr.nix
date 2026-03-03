{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-033";
    title = "Readarr";
    description = "E-Book and audiobook management agent with unified hardening.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/books" "automation/downloader" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.readarr;
  defs = config.my.defaults;
in
{
  options.my.meta.readarr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for readarr module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "readarr"; port = cfg.settings.server.port; useSSO = defs.security.ssoEnable; description = "Readarr"; netns = cfg.netns; })
    {
      systemd.services.readarr = {
        description = "Readarr"; after = [ "network.target" ]; wantedBy = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars "READARR" cfg.settings;
        serviceConfig = { Type = "simple"; User = cfg.user; Group = cfg.group; ExecStart = "${pkgs.readarr}/bin/Readarr -nobrowser -data='${cfg.stateDir}'"; ... } // factory.mkServarrHardening;
      };
    }
  ]);
}
