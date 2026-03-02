#!/usr/bin/env bash
# Cloudflare API Token Validator für OliveTin

TOKEN="$1"

if [ -z "$TOKEN" ]; then
    echo "❌ Fehler: Kein Token angegeben!"
    exit 1
fi

echo "Prüfe Token gegen Cloudflare API..."

# Token verifizieren
RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" 
     -H "Authorization: Bearer $TOKEN" 
     -H "Content-Type: application/json")

# Prüfen, ob "success": true in der Antwort steht (mit jq)
IS_VALID=$(echo "$RESPONSE" | jq -r '.success')
STATUS=$(echo "$RESPONSE" | jq -r '.messages[0].message')

if [ "$IS_VALID" == "true" ]; then
    echo "✅ ERFOLG: Der API Key ist GÜLTIG!"
    echo "Status: $STATUS"
    exit 0
else
    echo "❌ FEHLER: Der API Key ist UNGÜLTIG oder hat keine Rechte!"
    # Zeige die Fehlermeldung von Cloudflare an, bereinigt
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.errors[0].message')
    echo "Grund: $ERROR_MSG"
    exit 1
fi
