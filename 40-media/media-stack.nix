{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-033";
    title = "Media Stack (Exhausted Layout)";
    description = "Canonical data/state layout with ABC-tiering enforcement and global media permissions.";
    layer = 30;
    nixpkgs.category = "system/storage";
    capabilities = [ "storage/layout" "security/permissions" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  srePaths = config.my.configs.paths;
in
{
  options.my.meta.media_stack = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for media-stack module";
  };


  config = lib.mkIf config.my.services.mediaStack.enable {
    users.groups.media = { gid = 169; };
    users.groups.media.members = [ "jellyfin" "sabnzbd" "audiobookshelf" "sonarr" "radarr" "lidarr" "readarr" "prowlarr" ];
    systemd.tmpfiles.rules = [
      "d ${srePaths.mediaLibrary} 0775 root media -"
      "d ${srePaths.mediaLibrary}/movies 0775 radarr media -"
      "d ${srePaths.mediaLibrary}/tv 0775 sonarr media -"
      "d ${srePaths.mediaLibrary}/music 0775 lidarr media -"
      "d ${srePaths.mediaLibrary}/books 0775 readarr media -"
      "d ${srePaths.mediaLibrary}/documents 0775 paperless media -"
      "d ${srePaths.storagePool}/downloads 0775 root media -"
      "d ${srePaths.storagePool}/downloads/torrents 0775 prowlarr media -"
      "d ${srePaths.storagePool}/downloads/usenet 0775 sabnzbd media -"
      "d ${srePaths.stateDir} 0755 root root -"
      "d /mnt/fast-pool/metadata 0775 root media -"
      "d /mnt/fast-pool/cache 0775 root media -"
    ];
  };
}
