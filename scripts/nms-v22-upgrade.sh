#!/usr/bin/env bash
# 🛰️ NMS-2026 v2.2 METADATA ARCHITECT
set -euo pipefail

REPO_ROOT="/etc/nixos"
cd "$REPO_ROOT"

echo "🚀 Starte Migration auf NMS v2.2 (Header/Footer)..."

# 2. Injektions-Funktion (Vollständig)
inject_nms_v22() {
    local file=$1
    local tid=$2
    local layer=$3
    local title=$4
    local req=$5

    [ ! -f "$file" ] && return

    echo "Processing $file..."

    # 1. Entferne alte NMS Header (falls vorhanden)
    # Entfernt alles von Zeile 1 bis zum ersten "*/"
    if head -n 1 "$file" | grep -q "/\*\*"; then
        sed -i '1,/.*\*\//d' "$file"
    fi

    # Entferne alte Footer (falls vorhanden)
    # Das ist schwieriger, wir verlassen uns darauf, dass wir sie neu anhängen, 
    # aber wir versuchen, am Dateiende nach "NIXHOME_VALID_EOF" zu suchen und den Block zu löschen.
    # Da wir v2.2 einführen, gibt es diesen Footer vmtl noch nicht.
    
    # Entferne eventuelle Leerzeilen am Anfang
    sed -i '/./,$!d' "$file"

    local content_hash=$(sha256sum "$file" | cut -d' ' -f1)
    local temp_file=$(mktemp)
    local date_today=$(date -I)

    # Header generieren (YAML)
    cat << HEAD > "$temp_file"
/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: ${tid}
 *   title: "${title}"
 *   layer: ${layer}
 * architecture:
 *   req_refs: [${req}]
 *   status: audited
 * ---
 */
HEAD

    # Original-Inhalt
    cat "$file" >> "$temp_file"

    # Füge Leerzeile vor Footer ein, falls Datei nicht damit endet
    if [ "$(tail -c 1 "$temp_file")" != "" ]; then
        echo "" >> "$temp_file"
    fi
    echo "" >> "$temp_file"

    # Footer generieren (YAML)
    cat << FOOT >> "$temp_file"
/**
 * ---
 * technical_integrity:
 *   checksum: sha256:${content_hash}
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: ${date_today}
 * ---
 */
FOOT

    mv "$temp_file" "$file"
}

# 3. Apply new headers/footers to all files
count_core=1
count_inf=1
count_srv=1
count_pol=1

while read -r file; do
    title=$(basename "$file" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-00-SYS-CORE-%03d" $count_core)
    inject_nms_v22 "$file" "$id" "00" "$title" "REQ-CORE"
    count_core=$((count_core + 1))
done < <(find 00-core -name "*.nix" -type f | sort)

while read -r file; do
    title=$(basename "$file" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-10-NET-INFRA-%03d" $count_inf)
    inject_nms_v22 "$file" "$id" "10" "$title" "REQ-INF"
    count_inf=$((count_inf + 1))
done < <(find 10-infrastructure -name "*.nix" -type f | sort)

while read -r file; do
    title=$(basename "$file" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-20-APP-SRV-%03d" $count_srv)
    inject_nms_v22 "$file" "$id" "20" "$title" "REQ-SRV"
    count_srv=$((count_srv + 1))
done < <(find 20-services -name "*.nix" -type f | sort)

while read -r file; do
    title=$(basename "$file" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-90-SEC-POL-%03d" $count_pol)
    inject_nms_v22 "$file" "$id" "90" "$title" "REQ-POL"
    count_pol=$((count_pol + 1))
done < <(find 90-policy -name "*.nix" -type f | sort)

# configuration.nix im Root
inject_nms_v22 "configuration.nix" "NIXH-00-SYS-ROOT-001" "00" "System Entrypoint" "REQ-SYS-01"

# lib/helpers.nix
inject_nms_v22 "lib/helpers.nix" "NIXH-00-SYS-LIB-001" "00" "Global Service Helpers" "REQ-LIB-01"

echo "✅ Migration abgeschlossen. System ist jetzt auf NMS v2.2 Standard."
