#!/usr/bin/env bash
# Ingests a new API key directly into the SOPS secrets.yaml using the server's age key.

KEY_NAME="$1"
API_KEY="$2"
SOPS_FILE="/etc/nixos/secrets.yaml"
AGE_KEY="/etc/ssh/ssh_host_ed25519_key"

if [ -z "$KEY_NAME" ] || [ -z "$API_KEY" ]; then
    echo "❌ Fehler: Key-Name oder API-Key fehlt!"
    exit 1
fi

export SOPS_AGE_KEY_FILE="$AGE_KEY"

echo "Füge Secret '$KEY_NAME' zu $SOPS_FILE hinzu..."

# sops --set erwartet JSON-Syntax für den Pfad und den Wert. Wir packen den String in Anführungszeichen.
sops --set "["$KEY_NAME"] "$API_KEY"" "$SOPS_FILE"

if [ $? -eq 0 ]; then
    echo "✅ ERFOLG: Secret '$KEY_NAME' wurde sicher in sops gespeichert!"
    echo "Hinweis: Du musst 'nixos-rebuild switch' ausführen, um die Änderung auf das System anzuwenden."
    exit 0
else
    echo "❌ FEHLER: SOPS konnte die Datei nicht aktualisieren. Stimmt der Key-Name?"
    exit 1
fi
