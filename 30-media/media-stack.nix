/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-033
 *   title: "Media Stack (Exhausted Layout)"
 *   layer: 20
 * summary: Canonical data/state layout with ABC-tiering enforcement and global media permissions.
 * ---
 */
{ config, lib, ... }:
let
  srePaths = config.my.configs.paths;
in
{
  users.groups.media = {
    gid = 169;
  };

  # Shared media access across local services.
  users.groups.media.members = [ 
    "jellyfin" "sabnzbd" "audiobookshelf" "sonarr" "radarr" "lidarr" "readarr" "prowlarr" 
  ];

  # ── CANONICAL SRE LAYOUT ────────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    # Tier C: Bibliothek
    "d ${srePaths.mediaLibrary} 0775 root media -"
    "d ${srePaths.mediaLibrary}/movies 0775 radarr media -"
    "d ${srePaths.mediaLibrary}/tv 0775 sonarr media -"
    "d ${srePaths.mediaLibrary}/music 0775 lidarr media -"
    "d ${srePaths.mediaLibrary}/books 0775 readarr media -"
    "d ${srePaths.mediaLibrary}/documents 0775 paperless media -"

    # Tier B: Downloads
    "d ${srePaths.storagePool}/downloads 0775 root media -"
    "d ${srePaths.storagePool}/downloads/torrents 0775 prowlarr media -"
    "d ${srePaths.storagePool}/downloads/usenet 0775 sabnzbd media -"
    
    # Tier A: State & Metadata
    "d ${srePaths.stateDir} 0755 root root -"
    "d /mnt/fast-pool/metadata 0775 root media -"
    "d /mnt/fast-pool/cache 0775 root media -"
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
