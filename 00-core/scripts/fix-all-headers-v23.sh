#!/usr/bin/env bash
# 🛰️ NIXHOME MASTER HEADER FIXER (v2.3)
set -euo pipefail

REPO_ROOT="/etc/nixos"
cd "$REPO_ROOT"

inject_nms_v23() {
    local file=$1
    local tid=$2
    local layer=$3
    local title=$4
    local req=$5
    local upstream=$6
    local downstream=$7

    [ ! -f "$file" ] && return

    # Entferne ALLES bis zum Code (versuche Header und Footer zu treffen)
    # Header: Startet mit /** und endet mit */
    if head -n 1 "$file" | grep -q "/\*\*"; then
        sed -i '1,/.*\*\//d' "$file"
    fi
    # Footer: Startet mit /** am Ende der Datei
    # Wir löschen ab dem letzten vorkommen von /** bis zum Ende
    sed -i '/\/\*\*/,$d' "$file"

    # Bereinige Leerzeilen
    sed -i '/./,$!d' "$file"
    # Stelle sicher dass Datei mit einer Newline endet
    [ -n "$(tail -c 1 "$file")" ] && echo "" >> "$file"

    local content_hash=$(sha256sum "$file" | cut -d' ' -f1)
    local date_today=$(date -I)
    local temp_file=$(mktemp)

    cat << HEAD > "$temp_file"
/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: ${tid}
 *   title: "${title}"
 *   layer: ${layer}
 * architecture:
 *   req_refs: [${req}]
 *   upstream: [${upstream}]
 *   downstream: [${downstream}]
 *   status: audited
 * ---
 */
HEAD

    cat "$file" >> "$temp_file"

    cat << FOOT >> "$temp_file"

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:${content_hash}
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: ${date_today}
 *   complexity_score: 2
 * ---
 */
FOOT

    mv "$temp_file" "$file"
}

# Counter
c_00=1; c_10=1; c_20=1; c_90=1

# Process 00-core
find 00-core -name "*.nix" -type f | sort | while read -r f; do
    t=$(basename "$f" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-00-CORE-%03d" $c_00)
    inject_nms_v23 "$f" "$id" "00" "$t" "REQ-CORE" "NIXH-00-SYS-ROOT-001" ""
    c_00=$((c_00 + 1))
done

# Process 10-infrastructure
find 10-infrastructure -name "*.nix" -type f | sort | while read -r f; do
    t=$(basename "$f" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-10-INF-%03d" $c_10)
    inject_nms_v23 "$f" "$id" "10" "$t" "REQ-INF" "NIXH-00-SYS-ROOT-001" ""
    c_10=$((c_10 + 1))
done

# Process 20-services
find 20-services -name "*.nix" -type f | sort | while read -r f; do
    t=$(basename "$f" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-20-SRV-%03d" $c_20)
    inject_nms_v23 "$f" "$id" "20" "$t" "REQ-SRV" "NIXH-00-SYS-ROOT-001" ""
    c_20=$((c_20 + 1))
done

# Process 90-policy
find 90-policy -name "*.nix" -type f | sort | while read -r f; do
    t=$(basename "$f" .nix | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    id=$(printf "NIXH-90-POL-%03d" $c_90)
    inject_nms_v23 "$f" "$id" "90" "$t" "REQ-POL" "NIXH-00-SYS-ROOT-001" ""
    c_90=$((c_90 + 1))
done

# Special Files
inject_nms_v23 "configuration.nix" "NIXH-00-SYS-ROOT-001" "00" "System Entrypoint" "REQ-SYS-01" "" "NIXH-00-SYS-CORE-ALL"
inject_nms_v23 "lib/helpers.nix" "NIXH-00-SYS-LIB-001" "00" "Global Service Helpers" "REQ-LIB-01" "NIXH-00-SYS-ROOT-001" ""

echo "✨ All headers fixed and synchronized."
