# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Intelligente Speicher-Architektur (MergerFS + Smart Mover)

{ config, lib, pkgs, ... }:
let
  user = config.my.configs.identity.user;
  
  # Optimierte Mount-Optionen für HDDs (sink: reduce wakeups)
  hhdOptions = [
    "noatime"
    "nodiratime"
    "data=writeback"
    "commit=60"
    "nofail" # System bootet auch wenn Platte fehlt
  ];

  # MergerFS Cache-Optionen (sink: browse without wakeup)
  mergerfsOptions = [
    "cache.readdir=true"
    "cache.statfs=true"
    "cache.files=partial"
    "dropcacheonclose=true"
    "category.create=mfs" # Schreibt bevorzugt auf die Platte mit dem meisten freien Platz (innerhalb Tier B)
    "func.getattr=newest"
  ];
in
{
  # ── DATEISYSTEME ─────────────────────────────────────────────────────────
  
  fileSystems = {
    # Tier B: Cache/Work-Zone (SSD)
    # HINWEIS: Hier die UUID oder ID deiner Cache-SSD eintragen!
    "/mnt/cache" = {
      device = "/dev/disk/by-label/cache"; # Beispiel
      fsType = "ext4";
      options = hhdOptions;
    };

    # Tier C: Datengrab (HDDs)
    # HINWEIS: Hier deine HDDs eintragen!
    "/mnt/hdd1" = {
      device = "/dev/disk/by-label/hdd1"; # Beispiel
      fsType = "ext4";
      options = hhdOptions;
    };

    # MergerFS Pool: Kombiniert Cache (SSD) und HDDs
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
      # Konfiguration
      SRC="/mnt/cache"
      DST="/mnt/hdd1" # Erstes Ziel
      THRESHOLD=85
      DAYS=30

      # Prüfe Füllstand der SSD
      USAGE=$(${pkgs.coreutils}/bin/df --output=pcent "$SRC" | tail -1 | tr -dc '0-9')
      
      # Prüfe ob HDD dreht (hdparm)
      # Wir prüfen exemplarisch die erste HDD
      SPINNING=false
      if ${pkgs.hdparm}/bin/hdparm -C /dev/disk/by-label/hdd1 | grep -q "active/idle"; then
        SPINNING=true
      fi

      echo "Mover-Check: SSD Usage $USAGE%, HDD Spinning: $SPINNING"

      # LOGIK: Verschiebe wenn SSD zu voll (>85%) ODER wenn HDD sowieso dreht
      if [ "$USAGE" -gt "$THRESHOLD" ] || [ "$SPINNING" = true ]; then
        echo "Starte Datentransfer..."
        # Verschiebe Dateien die älter als X Tage sind
        ${pkgs.findutils}/bin/find "$SRC" -type f -mtime +$DAYS -exec ${pkgs.coreutils}/bin/mv -v {} "$DST" \;
        # Leere Ordner aufräumen
        ${pkgs.findutils}/bin/find "$SRC" -type d -empty -delete
      else
        echo "HDD schläft und SSD hat Platz. Mover übersprungen."
      fi
    '';
  };

  # Timer für den Mover (Stündlich)
  systemd.timers.smart-mover = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # ── TOOLS ────────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    mergerfs
    hdparm
  ];
}
