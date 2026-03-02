#!/usr/bin/env bash
# sink: NIXH-00-CORE-027 (Storage Module)
# NixHome Smart Mover (Precision & Power Edition)
# Moves files from Tier B (SSD) to Tier C (HDD) until a target fill level is reached.

# ── CONFIGURATION ──────────────────────────────────────────────────────────
B_ROOT="/mnt/fast-pool/downloads"
C_ROOT="/mnt/media"
TARGET_FILL=70       # Ziel: SSD auf 70% leeren
THRESHOLD_WARNING=75 # Ab hier nur schaufeln, wenn HDD eh dreht
THRESHOLD_CRITICAL=90 # Ab hier Spin-up erzwingen
AGE_DAYS=14          # Mindestalter der Dateien für Routine-Mover

# ── HELPERS ────────────────────────────────────────────────────────────────
get_usage() {
    df "$B_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//'
}

is_hdd_spinning() {
    # Prüft via Kernel-Status und hdparm
    for dev in /dev/sd[b-z]; do
        if [ -b "$dev" ] && [ "$(cat /sys/block/$(basename $dev)/queue/rotational 2>/dev/null)" = "1" ]; then
            # Prüfe den Power-Status direkt über den Kernel-Treiber (schont die Disk)
            power_state=$(cat "/sys/class/block/$(basename $dev)/device/power/runtime_status" 2>/dev/null)
            if [ "$power_state" = "active" ]; then return 0; fi
            
            # Fallback auf hdparm (nur Status-Abfrage, löst normal keinen Spin-up aus)
            if hdparm -C "$dev" 2>/dev/null | grep -q "active/idle"; then return 0; fi
        fi
    done
    return 1
}

move_until_target() {
    local max_age=$1
    echo "🚚 Starting precision move (Target: $TARGET_FILL% usage)..."
    
    # Finde Dateien, sortiert nach Alter (älteste zuerst)
    # Wir nehmen nur Dateien aus den Download-Verzeichnissen
    find "$B_ROOT" -type f -mtime +"$max_age" -not -path "*/incomplete/*" -printf "%T@ %p\n" | sort -n | cut -d' ' -f2- | while read -r FILE; do
        
        current_usage=$(get_usage)
        if [ "$current_usage" -le "$TARGET_FILL" ]; then
            echo "✅ Target reached ($current_usage%). Stopping move."
            break
        fi

        # Bestimme Zielpfad (Struktur beibehalten)
        REL_PATH="''${FILE#$B_ROOT/}"
        TARGET_DIR="$C_ROOT/$(dirname "$REL_PATH")"
        
        mkdir -p "$TARGET_DIR"
        echo "Moving: $REL_PATH (Current usage: $current_usage%)"
        
        # Sicherer Move via rsync
        rsync -a --remove-source-files "$FILE" "$TARGET_DIR/"
    done
}

# ── MAIN TRIGGER ───────────────────────────────────────────────────────────
USAGE=$(get_usage)

if [ "$USAGE" -ge "$THRESHOLD_CRITICAL" ]; then
    echo "🔴 CRITICAL: SSD at $USAGE%. Forcing move to $TARGET_FILL%."
    move_until_target 1 # Auch junge Dateien verschieben im Notfall
elif [ "$USAGE" -ge "$THRESHOLD_WARNING" ]; then
    echo "🟠 WARNING: SSD at $USAGE%."
    if is_hdd_spinning; then
        echo "✅ HDD is already spinning. Starting opportunistic move."
        move_until_target "$AGE_DAYS"
    else
        echo "💤 HDD is in standby. Skipping move to avoid spin-up."
    fi
else
    echo "🟢 OK: SSD at $USAGE%. No action needed."
fi

# Cleanup
find "$B_ROOT" -type d -empty -delete 2>/dev/null || true
echo "✨ Mover finished."
