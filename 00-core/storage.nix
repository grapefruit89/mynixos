# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Intelligente Speicher-Architektur (MergerFS + Smart Mover) - Optimized

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.storage-pool;
  
  # Optimierte Mount-Optionen für HDDs (IronicBadger-Style)
  hhdOptions = [
    "noatime"
    "nodiratime"
    "data=writeback"
    "commit=60"
    "nofail"
  ];

  # MergerFS Premium-Optionen (sink: browse without wakeup)
  mergerfsOptions = [
    "cache.readdir=true"
    "cache.statfs=true"
    "cache.files=partial"
    "dropcacheonclose=true"
    "category.create=mfs" # Most Free Space - verteilt Daten gleichmäßig
    "func.getattr=newest"
    "fsname=mergerfs-pool"
  ];
in
{
  config = lib.mkIf cfg.enable {
    # ── DATEISYSTEME ─────────────────────────────────────────────────────────
    fileSystems = {
      "/mnt/cache" = {
        device = "/dev/disk/by-label/cache";
        fsType = "ext4";
        options = hhdOptions;
      };

      "/mnt/hdd1" = {
        device = "/dev/disk/by-label/hdd1";
        fsType = "ext4";
        options = hhdOptions;
      };

      "/mnt/storage" = {
        device = "/mnt/cache:/mnt/hdd*";
        fsType = "fuse.mergerfs";
        options = mergerfsOptions;
        noCheck = true;
      };
    };

    # ── SMART MOVER SCRIPT ───────────────────────────────────────────────────
    systemd.services.smart-mover = {
      description = "Verschiebt alte Daten von SSD auf HDD (Smart Mover)";
      after = [ "mnt-storage.mount" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        SRC="/mnt/cache"
        DST="/mnt/hdd1"
        THRESHOLD=85
        DAYS=30

        USAGE=$(${pkgs.coreutils}/bin/df --output=pcent "$SRC" | tail -1 | tr -dc '0-9')
        
        SPINNING=false
        if ${pkgs.hdparm}/bin/hdparm -C /dev/disk/by-label/hdd1 2>/dev/null | grep -q "active/idle"; then
          SPINNING=true
        fi

        echo "Mover-Check: SSD Usage $USAGE%, HDD Spinning: $SPINNING"

        if [ -n "$USAGE" ] && ([ "$USAGE" -gt "$THRESHOLD" ] || [ "$SPINNING" = true ]); then
          echo "Starte Datentransfer..."
          ${pkgs.findutils}/bin/find "$SRC" -type f -mtime +$DAYS -exec ${pkgs.coreutils}/bin/mv -v {} "$DST" \;
          ${pkgs.findutils}/bin/find "$SRC" -type d -empty -delete
        else
          echo "HDD schläft und SSD hat Platz. Mover übersprungen."
        fi
      '';
    };

    systemd.timers.smart-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };

    environment.systemPackages = with pkgs; [
      mergerfs
      hdparm
    ];
  };
}
