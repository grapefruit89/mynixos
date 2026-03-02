#!/usr/bin/env bash
# scripts/scan-ids.sh
# meta:
#   owner: core
#   status: active
#   summary: Scannt alle .nix Dateien nach CFG.* IDs und generiert ids-report.md + ids-report.json
#
# Verwendung: bash /etc/nixos/scripts/scan-ids.sh
# Output: 00-core/ids-report.md und 00-core/ids-report.json (werden überschrieben)

set -euo pipefail

REPO_DIR="/etc/nixos"
REPORT_MD="${REPO_DIR}/00-core/ids-report.md"
REPORT_JSON="${REPO_DIR}/00-core/ids-report.json"

# Alle bekannten CFG-IDs sammeln (aus source-id Kommentaren)
mapfile -t ALL_IDS < <(
  grep -rn "source-id: CFG\." "${REPO_DIR}" \
    --include="*.nix" \
    --include="*.md" \
    | grep -oP 'source-id: \K(CFG\.[^\s]+)' \
    | sort -u
)

echo "Gefundene IDs: ${#ALL_IDS[@]}"

# Markdown generieren
{
  echo "# IDs Report (automatisch generiert)"
  echo ""
  echo "> Generiert von: scripts/scan-ids.sh"
  echo "> Stand: $(date -I)"
  echo ""

  for id in "${ALL_IDS[@]}"; do
    echo "## ${id}"
    echo ""
    echo "Sources:"

    # Quellen: Zeilen mit "source-id: ${id}"
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      echo "- /etc/nixos/${file}:${lineno}"
    done < <(grep -rn "source-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    echo ""
    echo "Sinks:"

    # Sinks: Zeilen wo die CFG-ID als Wert verwendet wird (sink-id Kommentar)
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      echo "- /etc/nixos/${file}:${lineno}"
    done < <(grep -rn "sink.*${id}\|# sink-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    echo ""
  done
} > "${REPORT_MD}"

# JSON generieren
{
  echo "{"
  first=true
  for id in "${ALL_IDS[@]}"; do
    if [ "$first" = true ]; then first=false; else echo ","; fi

    sources=()
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      sources+=(""${file}:${lineno}"")
    done < <(grep -rn "source-id: ${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    sinks=()
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1 | sed "s|${REPO_DIR}/||")
      lineno=$(echo "$line" | cut -d: -f2)
      sinks+=(""\/${file}:${lineno}"")
    done < <(grep -rn "sink.*${id}" "${REPO_DIR}" --include="*.nix" 2>/dev/null || true)

    sources_json=$(IFS=,; echo "${sources[*]:-}")
    sinks_json=$(IFS=,; echo "${sinks[*]:-}")

    printf '  "": {
    "sources": [],
    "sinks": []
  }' \
      "${id}" "${sources_json}" "${sinks_json}"
  done
  echo ""
  echo "}"
} > "${REPORT_JSON}"

echo "✅ Generiert:"
echo "   ${REPORT_MD}"
echo "   ${REPORT_JSON}"
