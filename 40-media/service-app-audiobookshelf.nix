{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-40-MED-002";
    title = "Audiobookshelf (SRE Hardened)";
    description = "Purposed-built audiobook and podcast server with standardized storage paths.";
    layer = 40;
    nixpkgs.category = "services/web-apps";
    capabilities = [ "media/audiobooks" "media/podcasts" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.audiobookshelf;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.audiobookshelf = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for audiobookshelf module";
  };


  config = lib.mkIf config.my.services.audiobookshelf.enable {
    services.audiobookshelf = { enable = true; host = "127.0.0.1"; port = port; group = "media"; };
    services.caddy.virtualHosts."abs.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.audiobookshelf.serviceConfig = { ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; ReadWritePaths = [ "/var/lib/audiobookshelf" "/mnt/media/books" "/mnt/media/podcasts" ]; NoNewPrivileges = true; SystemCallFilter = [ "@system-service" "~@privileged" ]; OOMScoreAdjust = -100; };
  };
}
