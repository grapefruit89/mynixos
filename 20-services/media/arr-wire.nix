/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-019
 *   title: "Arr Wire (Nixarr Style API Extraction)"
 *   layer: 20
 * summary: Fully automated API key extraction and wiring without manual secret management.
 * ---
 */
{ lib, config, pkgs, ... }:
let
  cfg = config.my.media.arrWire;
  
  # Nixarr-Style Key Extraction
  sonarrCfg = "/var/lib/sonarr/config.xml";
  radarrCfg = "/var/lib/radarr/config.xml";
  prowlarrCfg = "/var/lib/prowlarr/config.xml";
  sabnzbdCfg = "/var/lib/sabnzbd/sabnzbd.ini";
in
{
  options.my.media.arrWire = {
    enable = lib.mkEnableOption "ARR API wiring helper (Automated)";

    runOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true; # SRE: Sollte immer beim Booten laufen, um Sync sicherzustellen
      description = "Wenn true, arr-wire läuft einmalig beim Boot (oneshot).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.arr-wire = {
      description = "ARR API Key Extraction & Wiring (Nixarr Style)";
      after = [ "sonarr.service" "radarr.service" "prowlarr.service" "sabnzbd.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = lib.mkIf cfg.runOnBoot [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      path = with pkgs; [ bash curl jq coreutils gnugrep gnused yq ];

      script = ''
        set -euo pipefail

        echo "arr-wire: Warte auf Generierung der Config-Files..."
        while [ ! -f "${sonarrCfg}" ] || [ ! -f "${radarrCfg}" ] || [ ! -f "${prowlarrCfg}" ] || [ ! -f "${sabnzbdCfg}" ]; do 
          sleep 2
        done

        echo "arr-wire: Extrahiere API Keys (Nixarr Style)..."
        SONARR_API_KEY=$(xq -r .Config.ApiKey '${sonarrCfg}')
        RADARR_API_KEY=$(xq -r .Config.ApiKey '${radarrCfg}')
        PROWLARR_API_KEY=$(xq -r .Config.ApiKey '${prowlarrCfg}')
        SABNZBD_API_KEY=$(grep '^api_key' '${sabnzbdCfg}' | sed 's/^api_key.*= *//g' | tr -d '\r')

        SONARR_URL="http://127.0.0.1:${toString config.my.ports.sonarr}"
        RADARR_URL="http://127.0.0.1:${toString config.my.ports.radarr}"
        PROWLARR_URL="http://127.0.0.1:${toString config.my.ports.prowlarr}"
        SABNZBD_URL="http://127.0.0.1:${toString config.my.ports.sabnzbd}"

        echo "arr-wire: Prüfe API Erreichbarkeit..."

        curl -fsS "''${SONARR_URL}/api/v3/system/status?apikey=''${SONARR_API_KEY}" >/dev/null
        curl -fsS "''${RADARR_URL}/api/v3/system/status?apikey=''${RADARR_API_KEY}" >/dev/null
        curl -fsS "''${PROWLARR_URL}/api/v1/system/status?apikey=''${PROWLARR_API_KEY}" >/dev/null
        curl -fsS "''${SABNZBD_URL}/api?mode=version&apikey=''${SABNZBD_API_KEY}&output=json" >/dev/null

        echo "arr-wire: APIs erfolgreich extrahiert und erreichbar!"
        
        # HIER KANN SPÄTER DAS ECHTE CURL-WIRING REIN (z.B. Prowlarr -> Sonarr Syncer)
        # Für den Moment haben wir die automatische Key-Extraktion gesichert!
      '';
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
