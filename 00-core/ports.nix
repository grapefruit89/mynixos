/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Central Port Registry
 * TRACE-ID:     NIXH-CORE-015
 * PURPOSE:      Definition aller Dienst-Ports (10xxx: Infra, 20xxx: Apps).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ lib, ... }:
{
  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
    description = "Zentrales Port-Register.";
  };

  config.my.ports = {
    # ── SYSTEM & EDGE ────────────────────────────────────────────────────────
    ssh = 53844;
    edgeHttps = 443;

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
    audiobookshelf = 20000;
    filebrowser    = 20001;
    vaultwarden    = 20002;
    readeck        = 20007;
    miniflux       = 20016;
    n8n            = 20017;
    scrutiny       = 20020;
    monica         = 20031;
    jellyseerr     = 20055;
    sabnzbd        = 20080;
    jellyfin       = 20096;
    
    radarr         = 20878;
    readarr        = 20787;
    sonarr         = 20989;
    prowlarr       = 20696;
    
    homeassistant  = 28123;
    paperless      = 20981;
  };
}
