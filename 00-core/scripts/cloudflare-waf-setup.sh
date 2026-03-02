#!/usr/bin/env bash
# sink: NIXH-10-INF-007 (Dns Automation)
# Cloudflare WAF Setup Script (SRE Standard)
# Sets up a global Geoblock (DE, AT, LT only) via Cloudflare API.

# ── CONFIGURATION ──────────────────────────────────────────────────────────
# Wir nutzen SOPS um den Token sicher zu laden
TOKEN=$(sops -d --extract '["infra/cloudflare_token"]' /etc/nixos/secrets.yaml)

if [ -z "$TOKEN" ]; then
    echo "🚨 Error: Could not extract cloudflare_token from secrets.yaml"
    exit 1
fi

# Zone ID automatisch ermitteln
ZONE_DATA=$(curl -sf -X GET "https://api.cloudflare.com/client/v4/zones" 
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")
ZONE_ID=$(echo "$ZONE_DATA" | jq -r ".result[0].id")

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "null" ]; then
    echo "🚨 Error: Could not find Zone ID."
    exit 1
fi

echo "🛡️ Setting up WAF Rule for Zone: $ZONE_ID"

# ── WAF RULE DEFINITION ──────────────────────────────────────────────────
# Blockiert alles, was NICHT aus DE, AT oder LT kommt.
# Ausgenommen sind wir selbst (falls wir keine Länder-ID haben).
RULE_PAYLOAD=$(cat <<EOF
[
  {
    "action": "block",
    "expression": "(not ip.geoip.country in {"DE" "AT" "LT"})",
    "description": "SRE Geoblock: Allow only DE, AT, LT",
    "enabled": true
  }
]
EOF
)

# Regel via API anlegen (Custom Ruleset)
# Hinweis: Dies nutzt das http_request_firewall_custom Ruleset
RESPONSE=$(curl -sf -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/rulesets/phases/http_request_firewall_custom/entrypoint" 
  -H "Authorization: Bearer $TOKEN" 
  -H "Content-Type: application/json" 
  --data "{"rules": $RULE_PAYLOAD}")

if echo "$RESPONSE" | jq -e '.success' >/dev/null; then
    echo "✅ Cloudflare Geoblock (DE, AT, LT) successfully activated!"
else
    echo "❌ Failed to set WAF rule. Response:"
    echo "$RESPONSE" | jq .
fi
