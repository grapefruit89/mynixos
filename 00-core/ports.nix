/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-018
 *   title: "Ports"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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










/**
 * ---
 * technical_integrity:
 *   checksum: sha256:219c308ad38815b66429e3bad78add1282f12a57262fbc1f209ddb532d81cbb4
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
