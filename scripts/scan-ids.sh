#!/usr/bin/env bash
# scripts/scan-ids.sh
# meta:
#   owner: core
#   status: active
#   summary: Scannt alle .nix/.md Dateien nach CFG.* IDs und generiert ids-report.md + ids-report.json

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_MD="${REPO_DIR}/00-core/ids-report.md"
REPORT_JSON="${REPO_DIR}/00-core/ids-report.json"

mapfile -t ALL_IDS < <(
  rg -o --no-heading --no-filename 'source-id:\s*CFG\.[^[:space:]]+' "${REPO_DIR}" -g '*.nix' -g '*.md' \
    | sed -E 's/source-id:\s*//' \
    | sort -u
)

echo "Gefundene IDs: ${#ALL_IDS[@]}"

{
  echo "# IDs Report (automatisch generiert)"
  echo
  echo "> Generiert von: scripts/scan-ids.sh"
  echo "> Stand: $(date -Iseconds)"
  echo

  for id in "${ALL_IDS[@]}"; do
    echo "## ${id}"
    echo
    echo "Sources:"
    (rg -n --no-heading -F "source-id: ${id}" "${REPO_DIR}" -g '*.nix' -g '*.md' || true) | while IFS= read -r line; do
      file=${line%%:*}
      lineno=$(echo "$line" | cut -d: -f2)
      rel=${file#${REPO_DIR}/}
      echo "- ${rel}:${lineno}"
    done

    echo
    echo "Sinks:"
    (rg -n --no-heading -F "${id}" "${REPO_DIR}" -g '*.nix' -g '*.md' || true) | while IFS= read -r line; do
      file=${line%%:*}
      lineno=$(echo "$line" | cut -d: -f2)
      rel=${file#${REPO_DIR}/}
      echo "- ${rel}:${lineno}"
    done

    echo
  done
} > "${REPORT_MD}"

REPO_DIR_ENV="${REPO_DIR}" python3 - <<'PY' > "${REPORT_JSON}"
import json, os, pathlib, re

repo = pathlib.Path(os.environ['REPO_DIR_ENV'])
all_ids = set()
for p in repo.rglob('*'):
    if p.is_file() and p.suffix in {'.nix', '.md'}:
        text = p.read_text(errors='ignore')
        all_ids.update(re.findall(r'source-id:\s*(CFG\.[^\s]+)', text))

out = {}
for cid in sorted(all_ids):
    src = []
    sinks = []
    for p in repo.rglob('*'):
        if not (p.is_file() and p.suffix in {'.nix', '.md'}):
            continue
        rel = '/' + str(p.relative_to(repo))
        for i, line in enumerate(p.read_text(errors='ignore').splitlines(), start=1):
            if re.search(rf'source-id:\s*{re.escape(cid)}\b', line):
                src.append(f"{rel}:{i}")
            if re.search(rf'sink:.*{re.escape(cid)}\b', line) or re.search(rf'sink-id:\s*{re.escape(cid)}\b', line):
                sinks.append(f"{rel}:{i}")
    out[cid] = {"sources": src, "sinks": sinks}

print(json.dumps(out, indent=2, ensure_ascii=False))
PY

echo "✅ Generiert:"
echo "   ${REPORT_MD}"
echo "   ${REPORT_JSON}"
