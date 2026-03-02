/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-008
 *   title: "Dns Map (Dynamic SRE)"
 *   layer: 10
 * summary: Centralized DNS mapping with dynamic subdomain support.
 * ---
 */
let
  baseDomain = "m7c5.de";
  sub = "nix"; # 🛡️ SRE Standard Subdomain
  fullDomain = "${sub}.${baseDomain}";
in
{
  useNixSubdomain = true;
  dnsMapping = {
    jellyfin = "jellyfin.${fullDomain}";
    sonarr = "sonarr.${fullDomain}";
    radarr = "radarr.${fullDomain}";
    prowlarr = "prowlarr.${fullDomain}";
    readarr = "readarr.${fullDomain}";
    vault = "vault.${fullDomain}";
    auth = "auth.${fullDomain}";
    miniflux = "miniflux.${fullDomain}";
    monica = "monica.${fullDomain}";
    audiobookshelf = "audiobookshelf.${fullDomain}";
    paperless = "paperless.${fullDomain}";
    n8n = "n8n.${fullDomain}";
    scrutiny = "scrutiny.${fullDomain}";
    filebrowser = "filebrowser.${fullDomain}";
    sabnzbd = "sabnzbd.${fullDomain}";
    dashboard = "dash.${fullDomain}";
    homeassistant = "home.${fullDomain}";
    openwebui = "openwebui.${fullDomain}";
    agentzero = "agentzero.${fullDomain}";
  };
  baseDomain = baseDomain;
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
