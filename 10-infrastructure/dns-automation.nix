/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-10-NET-INFRA-007
 *   title: "Dns Automation"
 *   layer: 10
 *   req_refs: [REQ-INF]
 *   status: stable
 * traceability:
 *   parent: NIXH-10-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:5b9bd24e948594e59233706af5ec11ec15e7d497ba55d11c7858df11b88c7b1f"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
 */

{ config, pkgs, lib, ... }:
let
  runtimeDnsMap = "/var/lib/nixhome/dns-map-runtime.json";
  domain = config.my.configs.identity.domain;
in
{
  systemd.services.dns-guard = {
    description = "Check Cloudflare for DNS conflicts and update runtime map";
    after = [ "network-online.target" "sops-install-secrets.service" ];
    requires = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/nixhome";
      ExecStart = pkgs.writeShellScript "dns-guard-runtime" ''
        set -euo pipefail
        
        TOKEN=$(${pkgs.sops}/bin/sops -d --extract '["cloudflare_token"]' ${../secrets.yaml})
        
        ZONE_DATA=$(${pkgs.curl}/bin/curl -sf -X GET "https://api.cloudflare.com/client/v4/zones" \
          -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")
        ZONE_ID=$(echo "$ZONE_DATA" | ${pkgs.jq}/bin/jq -r ".result[0].id")
        EXISTING_RECORDS=$(${pkgs.curl}/bin/curl -sf -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" \
          -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" | ${pkgs.jq}/bin/jq -r ".result[].name")
        
        GLOBAL_CONFLICT=false
        for record in $EXISTING_RECORDS; do
            if [[ "$record" == "*.${domain}" ]]; then GLOBAL_CONFLICT=true; break; fi
        done
        
        ${pkgs.jq}/bin/jq -n \
          --arg subdomain "$GLOBAL_CONFLICT" \
          --arg domain "${domain}" \
          '{useNixSubdomain: ($subdomain == "true"), baseDomain: $domain}' \
          > "${runtimeDnsMap}"
        
        echo "Runtime DNS Map updated in ${runtimeDnsMap}"
      '';
    };
    path = with pkgs; [ curl jq coreutils gnugrep sops ];
  };

  systemd.timers.dns-guard = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30min";
    };
  };
}
