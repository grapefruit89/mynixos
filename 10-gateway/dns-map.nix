let
  # 🚀 NMS v4.0 Metadaten (Data File)
  nms = {
    id = "NIXH-10-INF-008";
    title = "Dns Map";
    description = "Static DNS mapping data for consistent routing across services.";
    layer = 10;
    nixpkgs.category = "data/networking";
    capabilities = [ "network/dns-map" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  baseDomain = "m7c5.de";
  sub = "nix";
  d = "${sub}.${baseDomain}";
in
{
  _meta = nms;
  useNixSubdomain = true;
  baseDomain = baseDomain;
  sub = sub;
  dnsMapping = {
    jellyfin = "jellyfin.${d}"; sonarr = "sonarr.${d}"; radarr = "radarr.${d}"; prowlarr = "prowlarr.${d}"; readarr = "readarr.${d}"; lidarr = "lidarr.${d}";
    audiobookshelf = "audiobookshelf.${d}"; sabnzbd = "sabnzbd.${d}"; jellyseerr = "jellyseerr.${d}";
    vault = "vault.${d}"; paperless = "paperless.${d}"; n8n = "n8n.${d}"; miniflux = "miniflux.${d}"; monica = "monica.${d}"; readeck = "readeck.${d}"; matrix = "matrix.${d}";
    auth = "auth.${d}"; dashboard = "dash.${d}"; adguard = "dns.${d}"; olivetin = "olivetin.local"; status = "status.${d}"; netdata = "netdata.${d}"; scrutiny = "scrutiny.${d}";
    filebrowser = "filebrowser.${d}"; homeassistant = "home.${d}"; openwebui = "openwebui.${d}"; cockpit = "admin.${d}"; ddns = "nix-ddns.${d}";
  };
}
