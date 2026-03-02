# =============================================================================
# 10-infrastructure/dns-map.nix
# =============================================================================
# HINWEIS: Dies ist eine pure Nix-Datensatzdatei (kein Modul).
# Sie wird mit `import ./dns-map.nix` geladen, nicht über das Modul-System.
#
# BEKANNTE EINSCHRÄNKUNG: Reines import kann nicht auf `config` zugreifen.
# Die Domain ist daher hier als Konstante gesetzt und muss mit
# configs.nix → identity.domain übereinstimmen.
#
# LANGFRISTIG: dns-map in ein echtes Modul umwandeln das config.my.configs.identity.domain
# liest — dann verschwindet die Dopplung. Ticket: NIXH-REFACTOR-DNS-MAP
# =============================================================================
let
  baseDomain = "m7c5.de";   # SYNC MIT: 00-core/configs.nix → identity.domain
  sub        = "nix";       # SYNC MIT: 00-core/configs.nix → identity.subdomain
  d          = "${sub}.${baseDomain}";
in
{
  useNixSubdomain = true;

  baseDomain = baseDomain;
  sub        = sub;

  dnsMapping = {
    # ── MEDIA ──────────────────────────────────────────────────────────────
    jellyfin       = "jellyfin.${d}";
    sonarr         = "sonarr.${d}";
    radarr         = "radarr.${d}";
    prowlarr       = "prowlarr.${d}";
    readarr        = "readarr.${d}";
    lidarr         = "lidarr.${d}";
    audiobookshelf = "audiobookshelf.${d}";
    sabnzbd        = "sabnzbd.${d}";
    jellyseerr     = "jellyseerr.${d}";

    # ── TOOLS ──────────────────────────────────────────────────────────────
    vault          = "vault.${d}";
    paperless      = "paperless.${d}";
    n8n            = "n8n.${d}";
    miniflux       = "miniflux.${d}";
    monica         = "monica.${d}";
    readeck        = "readeck.${d}";
    matrix         = "matrix.${d}";

    # ── INFRASTRUCTURE ─────────────────────────────────────────────────────
    auth           = "auth.${d}";
    dashboard      = "dash.${d}";
    adguard        = "dns.${d}";         # FIX: war fehlend → homepage.nix Fallback nötig
    olivetin       = "olivetin.local";   # FIX: war fehlend → homepage.nix Fallback nötig
    status         = "status.${d}";
    netdata        = "netdata.${d}";
    scrutiny       = "scrutiny.${d}";
    filebrowser    = "filebrowser.${d}";
    homeassistant  = "home.${d}";
    openwebui      = "openwebui.${d}";
    cockpit        = "admin.${d}";
    ddns           = "nix-ddns.${d}";
  };
}
