#!/usr/bin/env bash
# 🛰️ NIXHOME HEALTH REPORT GENERATOR
# =================================
# PURPOSE: Automatische Validierung der Traceability Matrix & Header Compliance.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
REPORT_FILE="${REPO_ROOT}/HEALTH_REPORT.md"

{
    echo "# 🛰️ NIXHOME SYSTEM HEALTH REPORT"
    echo "**Generated:** $(date -u)"
    echo ""
    echo "## 🛡️ Compliance Check (NMS-2026 Header)"
    
    # 1. Header Compliance Check
    MISSING_HEADERS=$(grep -rL "🛰️ NIXHOME CONFIGURATION UNIT" "${REPO_ROOT}/00-core" "${REPO_ROOT}/10-infrastructure" "${REPO_ROOT}/20-services" "${REPO_ROOT}/90-policy" --include="*.nix" || true)

    if [ -n "$MISSING_HEADERS" ]; then
        echo "⚠️ **WARNUNG:** Folgende Dateien fehlen NMS-2026 Header:"
        echo ""
        echo '```'
        echo "$MISSING_HEADERS" | sed "s|${REPO_ROOT}/||g"
        echo '```'
    else
        echo "✅ Alle .nix Dateien sind NMS-2026 konform."
    fi

    echo ""
    echo "## 📊 Traceability Matrix Summary"
    echo "| Trace-ID Prefix | Count |"
    echo "|:---|:---:|"
    
    # 2. Traceability IDs sammeln
    grep -r "TRACE-ID:" "${REPO_ROOT}" --include="*.nix" | awk '{print $NF}' | cut -d'-' -f1,2 | sort | uniq -c | awk '{print "| " $2 " | " $1 " |"}'

    echo ""
    echo "## 🔍 Detailed Trace-ID Inventory"
    echo '```'
    grep -r "TRACE-ID:" "${REPO_ROOT}" --include="*.nix" | awk -F': ' '{print $2}' | sort
    echo '```'

} > "${REPORT_FILE}"

echo "✨ Health Report updated in ${REPORT_FILE}"

