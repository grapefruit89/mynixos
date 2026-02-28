/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Storage
 * TRACE-ID:     NIXH-CORE-012
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:3d2f2886eb4bf8ac2682e8355f79f7a2ce96653344cb14cbf2a941b595417dae
 */

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.storage-pool;
  queueB = "/var/lib/nixhome/mover-queue-b.txt";
  queueC = "/var/lib/nixhome/mover-queue-c.txt";
  
  # Defensive Basis: Nie den Boot blockieren
  safeBase = [ "nofail" "X-systemd.mount-timeout=15s" "noatime" "nodiratime" ];
  sataOptions = safeBase ++ [ "discard" "commit=60" "data=writeback" ];
  hddOptions  = safeBase ++ [ "commit=60" "data=writeback" ];

  # MergerFS: Startet auch degradiert
  mergerfsOptions = [
    "nofail"
    "X-systemd.mount-timeout=30s"
    "cache.readdir=true"
    "cache.statfs=true"
    "category.create=ff"
    "dropcacheonclose=true"
    "fsname=nixhome-pool"
  ];
in
{
  config = lib.mkIf cfg.enable {
    # ── TIER-STRUKTUR (GODMODE) ──────────────────────────────────────────────
    # Topf A (NVMe):    /data/state (A-Daten) & /data/metadata (B-Daten Primär)
    # Topf B (SATA SSD): /mnt/fast-data (B-Daten Überlauf & C-Daten Cache)
    # Topf C (HDD):      /mnt/archive (C-Daten Archiv)

    fileSystems = {
      # Physische Mounts (Defensiv konfiguriert)
      "/mnt/fast-data" = { 
        device = "/dev/disk/by-label/tier-b"; 
        fsType = "ext4"; 
        options = sataOptions; 
      };
      "/mnt/archive" = { 
        device = "/dev/disk/by-label/tier-c"; 
        fsType = "ext4"; 
        options = hddOptions; 
      };

      # 🚀 POOL B: "Metadata-Pool"
      "/mnt/fast-pool" = {
        device = "/data/metadata:/mnt/fast-data/metadata-overflow";
        fsType = "fuse.mergerfs";
        options = mergerfsOptions;
        noCheck = true;
      };

      # 🎬 POOL C: "Media-Pool"
      "/mnt/media" = {
        device = "/mnt/fast-data/media-cache:/mnt/archive";
        fsType = "fuse.mergerfs";
        options = mergerfsOptions ++ [
          "cache.files=partial"
          "rename_atomic=true"
          "ignorepponrename=true"
        ];
        noCheck = true;
      };
    };

    # Warnung wenn kritische Tiers fehlen
    warnings = lib.optional (!builtins.pathExists "/dev/disk/by-label/tier-b") 
      "WARNUNG: /dev/disk/by-label/tier-b nicht gefunden. MergerFS läuft degradiert.";

    # Systemd-Tmpfiles für die Topf-Trennung
    systemd.tmpfiles.rules = [
      "d /var/lib/nixhome 0750 root root -"           # Mover Queue Verzeichnis
      "d /data/state 0750 moritz users -"             # Topf A: Reine DBs
      "d /data/metadata 0750 moritz users -"          # Topf A: B-Daten Primär
      "d /mnt/fast-data/metadata-overflow 0750 moritz users -" # Topf B: B-Daten Überlauf
      "d /mnt/fast-data/media-cache 0750 moritz users -"       # Topf B: C-Daten Cache
      "d /mnt/fast-data/media-cache/downloads 0750 moritz users -" # ATOMIC MOVES: Download-Ordner im Pool
    ];

    # 🛒 1. DIE EINKAUFSLISTEN (Nachts um 03:00)
    systemd.services.nixhome-mover-prepper = {
      description = "NixHome Mover Prepper: Erstellt Einkaufslisten";
      serviceConfig.Type = "oneshot";
      script = ''
        # Liste für B-Daten (A -> B)
        ${pkgs.findutils}/bin/find "/data/metadata" -type f -mtime +30 > /var/lib/nixhome/mover-queue-b.txt
        # Liste für C-Daten (B -> C)
        ${pkgs.findutils}/bin/find "/mnt/fast-data/media-cache" -type f -mtime +14 > /var/lib/nixhome/mover-queue-c.txt
      '';
    };

    # 🚚 2. DER INTELLIGENTE DOPPEL-MOVER
    systemd.services.nixhome-mover = {
      description = "NixHome Intelligent Mover: Dual-Tier Migration";
      serviceConfig.Type = "oneshot";
      script = ''
        set -euo pipefail
        get_usage() { ${pkgs.coreutils}/bin/df --output=pcent "$1" | tail -1 | tr -dc '0-9'; }
        
        # --- TEIL 1: B-DATEN (A -> B) ---
        # Wenn NVMe (/) > 80% -> Schiebe Metadaten auf SSD
        if [ $(get_usage "/") -gt 80 ]; then
          echo "⚠️ NVMe fast voll. Schiebe B-Daten auf SSD..."
          cat /var/lib/nixhome/mover-queue-b.txt | while read -r f; do
            [ -f "$f" ] && mv -v "$f" "/mnt/fast-data/metadata-overflow/"
            [ $(get_usage "/") -le 70 ] && break
          done
        fi

        # --- TEIL 2: C-DATEN (B -> C) ---
        # Wenn SSD > 85% ODER HDD dreht -> Schiebe Medien auf HDD
        SSD_USAGE=$(get_usage "/mnt/fast-data")
        HDD_SPINNING=$(${pkgs.hdparm}/bin/hdparm -C "/dev/disk/by-label/tier-c" 2>/dev/null | grep -q "active/idle" && echo true || echo false)
        
        if [ "$SSD_USAGE" -gt 85 ] || [ "$HDD_SPINNING" = "true" ]; then
          echo "🚚 Starte Media-Migration (SSD -> HDD)..."
          cat /var/lib/nixhome/mover-queue-c.txt | while read -r f; do
            [ -f "$f" ] && mv -v "$f" "/mnt/archive/"
            [ $(get_usage "/mnt/fast-data") -le 60 ] && break
          done
        fi
      '';
    };

    # Prüfe alle 10 Minuten opportunistisch
    systemd.timers.nixhome-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "5min"; OnUnitActiveSec = "10min"; };
    };

    environment.systemPackages = with pkgs; [ mergerfs hdparm procps sysstat ];
  };
}
