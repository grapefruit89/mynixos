/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-033
 *   title: "Media Stack"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
 */
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:1f0eaab8aeecf652ef51b1ac17ca762c290d9b6e14a485f4bb5b2f85ae4b6e31
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
