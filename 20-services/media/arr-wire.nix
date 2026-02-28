/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-019
 *   title: "Arr Wire"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ lib, config, pkgs, ... }:
let
  cfg = config.my.media.arrWire;
  envFile = config.my.secrets.files.sharedEnv;
in
{
  options.my.media.arrWire = {
    enable = lib.mkEnableOption "ARR API wiring helper (manuell + optional beim Boot)";

    runOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Wenn true, arr-wire läuft einmalig beim Boot (oneshot).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.arr-wire = {
      description = "ARR API wiring helper";
      after = [ "sonarr.service" "radarr.service" "prowlarr.service" "sabnzbd.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = lib.mkIf cfg.runOnBoot [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      path = with pkgs; [ bash curl jq coreutils gnugrep ];

      script = ''
        set -euo pipefail

        if [ ! -f "${envFile}" ]; then
          echo "arr-wire: missing env file ${envFile}" >&2
          exit 1
        fi

        source "${envFile}"

        : "''${SONARR_API_KEY:?SONARR_API_KEY missing in ${envFile}}"
        : "''${RADARR_API_KEY:?RADARR_API_KEY missing in ${envFile}}"
        : "''${PROWLARR_API_KEY:?PROWLARR_API_KEY missing in ${envFile}}"
        : "''${SABNZBD_API_KEY:?SABNZBD_API_KEY missing in ${envFile}}"

        SONARR_URL="''${SONARR_URL:-http://127.0.0.1:${toString config.my.ports.sonarr}}"
        RADARR_URL="''${RADARR_URL:-http://127.0.0.1:${toString config.my.ports.radarr}}"
        PROWLARR_URL="''${PROWLARR_URL:-http://127.0.0.1:${toString config.my.ports.prowlarr}}"
        SABNZBD_URL="''${SABNZBD_URL:-http://127.0.0.1:${toString config.my.ports.sabnzbd}}"

        echo "arr-wire: Prüfe API Erreichbarkeit..."

        curl -fsS "''${SONARR_URL}/api/v3/system/status?apikey=''${SONARR_API_KEY}" >/dev/null
        curl -fsS "''${RADARR_URL}/api/v3/system/status?apikey=''${RADARR_API_KEY}" >/dev/null
        curl -fsS "''${PROWLARR_URL}/api/v1/system/status?apikey=''${PROWLARR_API_KEY}" >/dev/null
        curl -fsS "''${SABNZBD_URL}/api?mode=version&apikey=''${SABNZBD_API_KEY}&output=json" >/dev/null

        echo "arr-wire: APIs erreichbar."
      '';
    };
  };
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:0138ae11890d660122a14c1e92bb8b62b7e77825e7f4f3b55af378183b4b7f89
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
