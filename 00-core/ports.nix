/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-018
 *   title: "Ports (SRE Master Source)"
 *   layer: 00
 * summary: Central port registry for consistent 10k/20k schema mapping.
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
    # source-id: PORT.ssh
    ssh = 53844;
    # source-id: PORT.edgeHttps
    edgeHttps = 443;

    # ── 10-INFRASTRUCTURE (10xxx) ───────────────────────────────────────────
    # source-id: PORT.adguard
    adguard     = 10000;
    # source-id: PORT.uptimeKuma
    uptimeKuma  = 10001;
    # source-id: PORT.pocketId
    pocketId    = 10010;
    # source-id: PORT.homepage
    homepage    = 10082;
    # source-id: PORT.netdata
    netdata     = 10999;

    # ── 20-SERVICES (20xxx) ─────────────────────────────────────────────────
    # source-id: PORT.jellyfin
    jellyfin       = 20096;
    # source-id: PORT.vaultwarden
    vaultwarden    = 20002;
    # source-id: PORT.n8n
    n8n            = 20017;
    # source-id: PORT.paperless
    paperless      = 20981;
    # source-id: PORT.sonarr
    sonarr         = 20989;
    # source-id: PORT.radarr
    radarr         = 20878;
    # source-id: PORT.prowlarr
    prowlarr       = 20696;
    # source-id: PORT.zigbee2mqtt
    zigbee2mqtt    = 28080;
    # source-id: PORT.mqtt
    mqtt           = 1883;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
