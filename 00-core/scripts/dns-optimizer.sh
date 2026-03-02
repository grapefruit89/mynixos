#!/usr/bin/env bash
# NixHome DNS Optimizer
# Prüft auf Konflikte in Cloudflare und schaltet .nix Subdomain um.

MAP_FILE="/etc/nixos/10-infrastructure/dns-map.nix"
RUNTIME_JSON="/var/lib/nixhome/dns-map-runtime.json"

if [ ! -f "$RUNTIME_JSON" ]; then
    echo "Führe erst den DNS-Guard Check aus..."
    sudo systemctl start dns-guard
    sleep 5
fi

USE_NIX=$(cat "$RUNTIME_JSON" | jq -r '.useNixSubdomain')

if [ "$USE_NIX" = "true" ]; then
    echo "Konflikt erkannt! Schalte auf .nix.m7c5.de um..."
    sed -i 's/useNixSubdomain = .*;/useNixSubdomain = true;/' "$MAP_FILE"
else
    echo "Kein Konflikt! Schalte auf saubere Subdomains (m7c5.de) um..."
    sed -i 's/useNixSubdomain = .*;/useNixSubdomain = false;/' "$MAP_FILE"
fi

echo "Änderungen übernommen. Starte System-Rebuild..."
sudo nixos-rebuild switch
