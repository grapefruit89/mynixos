#!/usr/bin/env bash
# 🛰️ NIXHOME INTEGRITY AUDITOR
set -euo pipefail
echo "🔍 Starte Integritäts-Prüfung..."
FAILED=0
while read -r file; do
    if grep -q "INTEGRITY: SHA256:" "$file"; then
        EXPECTED_HASH=$(grep "INTEGRITY: SHA256:" "$file" | cut -d':' -f3)
        ACTUAL_HASH=$(sed '1,/.*\*\//d' "$file" | sha256sum | cut -d' ' -f1)
        
        if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
            echo "❌ FAIL: $file"
            FAILED=1
        else
            echo "✅ OK: $file"
        fi
    fi
done < <(find . -name "*.nix" -type f)

[ $FAILED -eq 1 ] && exit 1 || echo "✨ Alle Dateien valide."
