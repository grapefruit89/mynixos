#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# mtls-generator.sh — Automatisierte mTLS-Client-Zertifikatserstellung
#
# Usage: bash mtls-generator.sh [client_name]
# Output: client.p12 (inkl. CA-Chain)
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

CLIENT_NAME="${1:-new-device}"
CERT_DIR="/etc/nixos/secrets/mtls"
CA_KEY="$CERT_DIR/ca.key"
CA_CRT="$CERT_DIR/ca.crt"
OUTPUT_DIR="/var/www/landing-zone/certs"

mkdir -p "$CERT_DIR" "$OUTPUT_DIR"

# 1. Erstelle CA falls nicht vorhanden
if [ ! -f "$CA_CRT" ]; then
    echo "🛡️ Generiere neue mTLS-Master-CA..."
    openssl genrsa -out "$CA_KEY" 4096
    openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 -out "$CA_CRT" 
        -subj "/CN=NixHome-MTLS-CA/O=Baumeister-SRE"
    chmod 600 "$CA_KEY"
fi

# 2. Generiere Client-Zertifikat
echo "🔑 Generiere Zertifikat für: $CLIENT_NAME..."
CLIENT_KEY="$CERT_DIR/$CLIENT_NAME.key"
CLIENT_CSR="$CERT_DIR/$CLIENT_NAME.csr"
CLIENT_CRT="$CERT_DIR/$CLIENT_NAME.crt"
CLIENT_P12="$OUTPUT_DIR/$CLIENT_NAME.p12"

openssl genrsa -out "$CLIENT_KEY" 2048
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -subj "/CN=$CLIENT_NAME"
openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial 
    -out "$CLIENT_CRT" -days 365 -sha256

# 3. Exportiere als .p12 (für einfachen Import in Browser/Handy)
# Passwort ist leer (für Homelab-Usage vertretbar, Zertifikat ist der Schutz)
openssl pkcs12 -export -out "$CLIENT_P12" -inkey "$CLIENT_KEY" -in "$CLIENT_CRT" 
    -certfile "$CA_CRT" -passout pass:

# 4. Cleanup & Permissions
rm "$CLIENT_CSR"
chmod 644 "$CLIENT_P12"
chown caddy:caddy "$CLIENT_P12"

echo "✅ Erfolg! Zertifikat erstellt: $CLIENT_P12"
echo "------------------------------------------------------"
echo "📥 DOWNLOAD LINK: https://nix.m7c5.de/certs/$CLIENT_NAME.p12"
echo "------------------------------------------------------"
echo "(Hinweis: Zertifikat im Browser importieren, Passwort ist leer)"
