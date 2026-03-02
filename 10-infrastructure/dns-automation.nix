/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-007
 *   title: "Dns Automation"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-022]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, pkgs, lib, ... }:
let
  runtimeDnsMap = "/var/lib/nixhome/dns-map-runtime.json";
  # source: CFG.identity.domain → 00-core/configs.nix
  domain        = config.my.configs.identity.domain;
  # source: secrets."infra/cloudflare_token" → 00-core/secrets.nix
  # FIX: sops-nix entschlüsselt zur Laufzeit → Pfad aus config lesen, kein sops-CLI nötig
  cfTokenFile   = config.sops.secrets.cloudflare_token.path;
in
{
  systemd.services.dns-guard = {
    description = "Check Cloudflare for DNS conflicts and update runtime map";
    after    = [ "network-online.target" "sops-install-secrets.service" ];
    requires = [ "network-online.target" ];

    serviceConfig = {
      Type           = "oneshot";
      # FIX: StateDirectory statt manuelles mkdir (systemd verwaltet das)
      StateDirectory = "nixhome";
      ExecStart      = pkgs.writeShellScript "dns-guard-runtime" ''
        set -euo pipefail

        # FIX 1: sops-nix entschlüsselt den Token bereits nach ${cfTokenFile}
        #         Kein sops-CLI + relativer Pfad mehr nötig (war fehlerhaft)
        TOKEN=$(cat "${cfTokenFile}")

        # FIX 2: Absoluter Pfad zur secrets.yaml war nicht nötig — Token kommt aus sops-nix

        ZONE_DATA=$(${pkgs.curl}/bin/curl -sf -X GET "https://api.cloudflare.com/client/v4/zones" \
          -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")

        ZONE_ID=$(echo "$ZONE_DATA" | ${pkgs.jq}/bin/jq -r ".result[0].id")

        if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "null" ]; then
          echo "FEHLER: Cloudflare Zone-ID nicht gefunden. Token korrekt?" >&2
          exit 1
        fi

        EXISTING_RECORDS=$(${pkgs.curl}/bin/curl -sf \
          "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" \
          -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
          | ${pkgs.jq}/bin/jq -r ".result[].name")

        GLOBAL_CONFLICT=false
        for record in $EXISTING_RECORDS; do
          if [[ "$record" == "*.${domain}" ]]; then
            GLOBAL_CONFLICT=true
            break
          fi
        done

        ${pkgs.jq}/bin/jq -n \
          --argjson conflict "$GLOBAL_CONFLICT" \
          --arg domain "${domain}" \
          '{useNixSubdomain: $conflict, baseDomain: $domain}' \
          > "${runtimeDnsMap}"

        echo "DNS-Guard: Runtime-Map aktualisiert (Konflikt: $GLOBAL_CONFLICT)"
      '';
    };

    path = with pkgs; [ curl jq coreutils gnugrep ];
  };

  systemd.timers.dns-guard = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec         = "1min";
      OnUnitActiveSec   = "30min";
      RandomizedDelaySec = "60";
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - BUG FIX: sops -d --extract '["cloudflare_token"]' → cat sops-nix-Pfad
 *       (falscher SOPS-Key: "cloudflare_token" statt "infra/cloudflare_token")
 *     - BUG FIX: ../secrets.yaml relativer Pfad → Token kommt aus sops-nix (absoluter Pfad)
 *     - StateDirectory statt manuelles mkdir
 *     - Zone-ID Fehlerbehandlung ergänzt
 *     - sops aus path entfernt (nicht mehr benötigt)
 *     - jq -n mit --argjson für korrektes Boolean-Handling
 * ---
 */
