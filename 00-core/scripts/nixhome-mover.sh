#!/usr/bin/env bash
# NixHome Mover Script
# Moves files from Tier B (SSD) to Tier C (HDD) if they are older than 30 days
# or if Tier B usage exceeds 80%.

B_DIR="/mnt/storage/ssd"
C_DIR="/mnt/storage/hdd"

if [ ! -d "$B_DIR" ] || [ ! -d "$C_DIR" ]; then
    echo "Storage tiers not available. Exiting."
    exit 0
fi

# Check usage of Tier B
USAGE=$(df -h | grep "$B_DIR" | awk '{print $5}' | sed 's/%//')
if [ -z "$USAGE" ]; then
    USAGE=0
fi

echo "Current Tier B Usage: ${USAGE}%"

if [ "$USAGE" -gt 80 ]; then
    echo "Tier B usage over 80%. Starting emergency move..."
    # Move files older than 7 days to free up space
    find "$B_DIR" -type f -mtime +7 -exec bash -c '
        FILE="{}"
        REL_PATH="${FILE#$B_DIR/}"
        TARGET_DIR="$C_DIR/$(dirname "$REL_PATH")"
        mkdir -p "$TARGET_DIR"
        mv "$FILE" "$TARGET_DIR/"
    ' \;
else
    echo "Tier B usage normal. Starting routine move (30 days)..."
    # Move files older than 30 days
    find "$B_DIR" -type f -mtime +30 -exec bash -c '
        FILE="{}"
        REL_PATH="${FILE#$B_DIR/}"
        TARGET_DIR="$C_DIR/$(dirname "$REL_PATH")"
        mkdir -p "$TARGET_DIR"
        mv "$FILE" "$TARGET_DIR/"
    ' \;
fi

# Cleanup empty directories
find "$B_DIR" -type d -empty -delete

echo "Mover finished."