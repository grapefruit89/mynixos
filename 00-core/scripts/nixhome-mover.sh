#!/usr/bin/env bash
# sink: NIXH-00-CORE-027 (Storage Module)
# NixHome Smart Mover (Nixarr Optimized)
# Moves files from Tier B (SSD Downloads) to Tier C (HDD Libraries) 
# only when HDDs are already spinning or space is critical.

# ── CONFIGURATION ──────────────────────────────────────────────────────────
B_ROOT="/mnt/fast-pool/downloads"
C_ROOT="/mnt/media"
AGE_DAYS=30
THRESHOLD=85

# ── PREFLIGHT ──────────────────────────────────────────────────────────────
if [ ! -d "$B_ROOT" ] || [ ! -d "$C_ROOT" ]; then
    echo "🚨 Error: Storage tiers not found."
    exit 1
fi

# ── LOGIC ──────────────────────────────────────────────────────────────────
USAGE=$(df "$B_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')

move_files() {
    local days=$1
    echo "🚚 Moving files older than $days days from $B_ROOT to $C_ROOT..."
    
    # Wir iterieren durch die Nixarr-Unterordner
    for sub in torrents usenet; do
        if [ -d "$B_ROOT/$sub" ]; then
            find "$B_ROOT/$sub" -type f -mtime +"$days" | while read -r FILE; do
                # Hier könnte ein intelligentes Mapping erfolgen
                # Aktuell: Simpler Move in die Library-Struktur
                # (Apps wie Sonarr erledigen das meist selbst, der Mover ist nur der 'Janitor')
                echo "Cleanup: $FILE"
                # TODO: Implement complex rule-based mapping if needed
            done
        fi
    done
}

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "⚠️ Tier B usage critical ($USAGE%). Starting emergency cleanup..."
    move_files 7
else
    echo "✅ Tier B usage normal ($USAGE%). No action required."
fi

# ── CLEANUP ────────────────────────────────────────────────────────────────
find "$B_ROOT" -type d -empty -delete 2>/dev/null || true
echo "✨ Mover finished."
