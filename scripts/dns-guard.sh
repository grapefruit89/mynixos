#!/usr/bin/env bash
# DNS-Guard v2: Isomorph-Modus
# source: /etc/nixos/scripts/dns-guard.sh

SECRETS="/etc/nixos/.local-secrets.nix"
OUTPUT="/etc/nixos/10-infrastructure/dns-map.nix"

TOKEN=$(grep "cloudflare =" "$SECRETS" | cut -d "\"" -f 2)

# 1. Zone & Domain holen
ZONE_DATA=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")
ZONE_ID=$(echo "$ZONE_DATA" | jq -r ".result[0].id")
DOMAIN=$(echo "$ZONE_DATA" | jq -r ".result[0].name")

# 2. Records holen
EXISTING_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" | jq -r ".result[].name")

# 3. Globalen Konflikt-Check (Wildcard oder Einzeleinträge)
GLOBAL_CONFLICT=false
for record in $EXISTING_RECORDS; do
    if [[ "$record" == "*.$DOMAIN" ]]; then
        echo "🚩 Wildcard-Konflikt erkannt (*.$DOMAIN)"
        GLOBAL_CONFLICT=true
        break
    fi
done

# Falls noch kein Wildcard-Konflikt, prüfe ob Dienste belegt sind
SERVICES=("jellyfin" "traefik" "sonarr" "radarr" "prowlarr" "readarr" "vault" "auth")
if [ "$GLOBAL_CONFLICT" = false ]; then
    for s in "${SERVICES[@]}"; do
        if echo "$EXISTING_RECORDS" | grep -q "^$s.$DOMAIN$"; then
            echo "🚩 Einzelservice-Konflikt erkannt ($s.$DOMAIN)"
            GLOBAL_CONFLICT=true
            break
        fi
    done
fi

# 4. Map generieren
echo "{" > $OUTPUT
echo "  useNixSubdomain = $GLOBAL_CONFLICT;" >> $OUTPUT
echo "  dnsMapping = {" >> $OUTPUT

for s in "${SERVICES[@]}"; do
    if [ "$GLOBAL_CONFLICT" = true ]; then
        echo "    $s = \"$s.nix.$DOMAIN\";" >> $OUTPUT
    else
        echo "    $s = \"$s.$DOMAIN\";" >> $OUTPUT
    fi
done

# Spezialfall Dashboard (immer erreichbar)
echo "    dashboard = \"nixhome.$DOMAIN\";" >> $OUTPUT
echo "  };" >> $OUTPUT
echo "  baseDomain = \"$DOMAIN\";" >> $OUTPUT
echo "}" >> $OUTPUT

echo "✅ Isomorpher DNS-Zustand geschrieben (Subdomain-Modus: $GLOBAL_CONFLICT)"
