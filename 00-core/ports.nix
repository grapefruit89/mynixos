# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: ports Modul (Zentrale Register-Struktur 10k/20k)

{ lib, ... }:
{
  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
    description = "Zentrales Port-Register. 10xxx = Infrastruktur, 20xxx = Services.";
  };

  config.my.ports = {
    # ── SYSTEM & EDGE ────────────────────────────────────────────────────────
    ssh = 53844;
    traefikHttps = 443;

    # ── 10-INFRASTRUCTURE (10xxx) ───────────────────────────────────────────
    adguard     = 10000;
    uptimeKuma  = 10001;
    ddnsUpdater = 10002;
    pocketId    = 10010;
    landingZoneUI = 10022;
    homepage    = 10082;
    netdata     = 10999;
    cockpit     = 10090;

    # ── 20-SERVICES (20xxx) ─────────────────────────────────────────────────
    # Media-Stack
    audiobookshelf = 20000;
    filebrowser = 20001;
    vaultwarden    = 20002;
    readeck        = 20007;
    miniflux       = 20016;
    n8n            = 20017;
    scrutiny       = 20020;
    monica         = 20031; # Wait, user wanted 20xxx
    jellyseerr     = 20055;
    sabnzbd        = 20080;
    jellyfin       = 20096;
    
    # Arr-Stack
    radarr         = 20878;
    readarr        = 20787;
    sonarr         = 20989;
    prowlarr       = 20696;
    
    # Automation
    homeassistant  = 28123;
    
    # Tools
    paperless      = 20981;
  };
}
