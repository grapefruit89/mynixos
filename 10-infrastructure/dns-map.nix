/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-008
 *   title: "Dns Map"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{
  useNixSubdomain = true;
  dnsMapping = {
    jellyfin = "jellyfin.nix.m7c5.de";
    sonarr = "sonarr.nix.m7c5.de";
    radarr = "radarr.nix.m7c5.de";
    prowlarr = "prowlarr.nix.m7c5.de";
    readarr = "readarr.nix.m7c5.de";
    vault = "vault.nix.m7c5.de";
    auth = "auth.nix.m7c5.de";
    miniflux = "miniflux.nix.m7c5.de";
    monica = "monica.nix.m7c5.de";
    audiobookshelf = "audiobookshelf.nix.m7c5.de";
    paperless = "paperless.nix.m7c5.de";
    n8n = "n8n.nix.m7c5.de";
    scrutiny = "scrutiny.nix.m7c5.de";
    filebrowser = "filebrowser.nix.m7c5.de";
    sabnzbd = "nix-sabnzbd.m7c5.de";
    dashboard = "nixhome.m7c5.de";
    homeassistant = "home.nix.m7c5.de";
  };
  baseDomain = "m7c5.de";
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:a96ca2838e4eb29ae8173aed55e28ec531e3f9045fa7f25fb7914dcf47c3b05b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
