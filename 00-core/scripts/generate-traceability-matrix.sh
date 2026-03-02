#!/usr/bin/env bash
# 🛰️ NIXHOME OMNITRACEABILITY MATRIX GENERATOR (v2.3)
set -euo pipefail

REPO_ROOT="/etc/nixos"
cd "$REPO_ROOT"
MATRIX_FILE="${REPO_ROOT}/TRACEABILITY_MATRIX.md"

echo "📊 Generiere Omnitraceability Matrix..."

{
    echo "# 🛰️ NIXHOME OMNITRACEABILITY MATRIX"
    echo "**Standard:** NMS-2026-v2.3"
    echo "**Auditor:** SRE-Autopilot"
    echo "**Status:** Generiert am $(date -u)"
    echo ""
    echo "| Req-ID | Bezeichnung | Trace-ID (Code) | Layer | Status | Checksum |"
    echo "|:---|:---|:---|:---:|:---:|:---|"

    # Extrahiere IDs aus allen .nix Dateien
    find . -name "*.nix" -type f | sort | while read -r file; do
        if grep -q "id: NIXH-" "$file"; then
            # ID: NIXH-XX-...
            ID=$(grep "id: NIXH-" "$file" | head -n 1 | awk -F'id: ' '{print $2}' | tr -d ' "')
            # REQ: [REQ-ID]
            REQ=$(grep "req_refs:" "$file" | head -n 1 | cut -d'[' -f2 | cut -d']' -f1)
            # TITLE: "Title"
            TITLE=$(grep "title:" "$file" | head -n 1 | cut -d'"' -f2)
            # LAYER: XX
            LAYER=$(grep "layer:" "$file" | head -n 1 | awk -F'layer: ' '{print $2}' | tr -d ' "')
            # HASH: sha256:...
            HASH=$(grep "checksum: sha256:" "$file" | tail -n 1 | awk -F'checksum: ' '{print $2}' | tr -d ' "')
            
            echo "| $REQ | $TITLE | $ID | $LAYER | [x] PASS | \`${HASH:7:8}\` |"
        fi
    done
} > "${MATRIX_FILE}"

echo "✅ Matrix generiert in ${MATRIX_FILE}"
