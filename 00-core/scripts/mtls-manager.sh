#!/usr/bin/env bash
# NixHome mTLS Manager
# Erstellt und verwaltet Client-Zertifikate für maximale Browser-Sicherheit.

STATE_DIR="/data/state/mtls"
mkdir -p "$STATE_DIR"
chmod 755 "$STATE_DIR"

CA_KEY="$STATE_DIR/ca.key"
CA_CRT="$STATE_DIR/ca.crt"
CLIENT_NAME="${1:-user-$(date +%s)}"
PASS="nixhome" # Einfaches Export-Passwort für p12

# 1. Root CA erstellen falls nicht vorhanden
if [ ! -f "$CA_KEY" ]; then
    echo "Initializing Root CA..."
    openssl genrsa -out "$CA_KEY" 4096
    openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 \
        -subj "/C=DE/ST=NixHome/L=Homelab/O=NixHome/CN=NixHome-Root-CA" \
        -out "$CA_CRT"
    chmod 600 "$CA_KEY"
    chmod 644 "$CA_CRT"
fi

# 2. Client Zertifikat erstellen
echo "Generating client certificate for: $CLIENT_NAME"
openssl genrsa -out "$STATE_DIR/$CLIENT_NAME.key" 2048
openssl req -new -key "$STATE_DIR/$CLIENT_NAME.key" \
    -subj "/CN=$CLIENT_NAME" \
    -out "$STATE_DIR/$CLIENT_NAME.csr"

openssl x509 -req -in "$STATE_DIR/$CLIENT_NAME.csr" \
    -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$STATE_DIR/$CLIENT_NAME.crt" -days 365 -sha256

# 3. p12 Bundle für Browser-Import erstellen
openssl pkcs12 -export -out "$STATE_DIR/$CLIENT_NAME.p12" \
    -inkey "$STATE_DIR/$CLIENT_NAME.key" \
    -in "$STATE_DIR/$CLIENT_NAME.crt" \
    -certfile "$CA_CRT" -passout "pass:$PASS"

# Berechtigungen für Web-Download setzen
chmod 644 "$STATE_DIR/$CLIENT_NAME.p12"
chmod 644 "$STATE_DIR/$CLIENT_NAME.crt"

echo "----------------------------------------------------"
echo "ERFOLG: Zertifikat erstellt!"
echo "Pfad: $STATE_DIR/$CLIENT_NAME.p12"
echo "Browser-Download: http://nixhome.local/certs/$CLIENT_NAME.p12"
echo "Passwort für Import: $PASS"
echo "----------------------------------------------------"
