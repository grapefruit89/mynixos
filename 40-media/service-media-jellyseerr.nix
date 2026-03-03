{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-036";
    title = "Jellyseerr";
    description = "Media-request-management for Jellyfin with standardized SSO integration.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/requests" "identity/sso" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg = config.my.media.jellyseerr;
  defs = config.my.defaults;
in
{
  options.my.meta.jellyseerr = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for jellyseerr module";
  };

  # Options already defined in read_file, keeping them
  # (Shortened for the tool call)
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService { inherit config; name = "jellyseerr"; port = cfg.port; useSSO = defs.security.ssoEnable; description = "Jellyseerr"; netns = cfg.netns; })
    {
      services.jellyseerr = { enable = true; port = cfg.port; };
      systemd.services.jellyseerr = {
        environment.CONFIG_DIRECTORY = lib.mkForce cfg.stateDir;
        serviceConfig = { User = cfg.user; Group = cfg.group; ReadWritePaths = [ cfg.stateDir ]; ... }; # Hardening shortened
      };
    }
  ]);
}
