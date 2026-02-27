#!/usr/bin/env bash
set -euo pipefail
SECRETS="/etc/nixos/secrets.env"
OUTPUT="/etc/nixos/10-infrastructure/dns-map.nix"
TOKEN=$(grep "CLOUDFLARE_TOKEN=" "$SECRETS" | cut -d '"' -f 2)
ZONE_DATA=$(curl -sf -X GET "https://api.cloudflare.com/client/v4/zones" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")
ZONE_ID=$(echo "$ZONE_DATA" | jq -r ".result[0].id")
DOMAIN=$(echo "$ZONE_DATA" | jq -r ".result[0].name")
EXISTING_RECORDS=$(curl -sf -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" | jq -r ".result[].name")
GLOBAL_CONFLICT=false
for record in $EXISTING_RECORDS; do
    if [[ "$record" == "*.$DOMAIN" ]]; then GLOBAL_CONFLICT=true; break; fi
done
SERVICES="jellyfin traefik sonarr radarr prowlarr readarr vault auth miniflux monica audiobookshelf paperless n8n scrutiny filebrowser"
if [ "$GLOBAL_CONFLICT" = false ]; then
    for s in $SERVICES; do
        if echo "$EXISTING_RECORDS" | grep -q "^$s.$DOMAIN$"; then GLOBAL_CONFLICT=true; break; fi
    done
fi
{
  echo "{"
  echo "  useNixSubdomain = $GLOBAL_CONFLICT;"
  echo "  dnsMapping = {"
  for s in $SERVICES; do
    if [ "$GLOBAL_CONFLICT" = true ]; then
        echo "    $s = \"$s.nix.$DOMAIN\";"
    else
        echo "    $s = \"$s.$DOMAIN\";"
    fi
  done
  echo "    dashboard = \"nixhome.$DOMAIN\";"
  echo "  };"
  echo "  baseDomain = \"$DOMAIN\";"
  echo "}"
} > "$OUTPUT"
echo "Success"
