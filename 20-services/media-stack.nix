{ lib, ... }:
{
  users.groups.media = {};

  # Shared media access across local services.
  users.groups.media.members = [ "jellyfin" "sabnzbd" "audiobookshelf" ];

  # Canonical data/state layout for backups and predictable permissions.
  systemd.tmpfiles.rules = [
    "d /data 0775 root media -"
    "d /data/media 0775 root media -"
    "d /data/media/movies 0775 jellyfin media -"
    "d /data/media/shows 0775 jellyfin media -"
    "d /data/media/music 0775 jellyfin media -"
    "d /data/media/books 0775 audiobookshelf media -"
    "d /data/downloads 0775 sabnzbd media -"

    "d /data/state 0755 root root -"
    "d /data/state/n8n 0750 n8n n8n -"
    "d /data/state/homepage 0755 homepage homepage -"
    "d /data/state/sabnzbd 0750 sabnzbd sabnzbd -"
  ];
}
