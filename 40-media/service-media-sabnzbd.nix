{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-035";
    title = "Sabnzbd";
    description = "Usenet download client with automated path enforcement and SSO support.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/usenet" "automation/downloader" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.sabnzbd;
  defs = config.my.defaults;
in
{
  options.my.meta.sabnzbd = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for sabnzbd module";
  };

  # Options already defined, keeping them
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "sabnzbd"; port = cfg.port; useSSO = defs.security.ssoEnable; description = "SABnzbd"; netns = cfg.netns; })
    {
      services.sabnzbd = { enable = true; user = cfg.user; group = cfg.group; };
      systemd.services.sabnzbd = {
        environment.SAB_CONFIG_FILE = "${cfg.stateDir}/sabnzbd.ini";
        serviceConfig = { User = cfg.user; Group = cfg.group; ReadWritePaths = [ cfg.stateDir defs.paths.downloadsDir ]; ... }; # Hardening shortened
      };
    }
  ]);
}
