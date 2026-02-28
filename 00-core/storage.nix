# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: 3-Tier ABC Speicher-Architektur (NVMe -> SATA SSD -> HDD) mit Einkaufslisten-Logik

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.storage-pool;
  queueFile = "/var/lib/nixhome/mover-queue.txt";
  
  sataOptions = [ "noatime" "nodiratime" "discard" "commit=30" ];
  hddOptions  = [ "noatime" "nodiratime" "nofail" "X-systemd.mount-timeout=10s" ];

in
{
  config = lib.mkIf cfg.enable {
    fileSystems = {
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

      "/mnt/media" = {
        device = "/mnt/fast-data:/mnt/archive";
        fsType = "fuse.mergerfs";
        options = [
          "cache.readdir=true"
          "cache.statfs=true"
          "category.create=ff"
          "func.getattr=newest"
          "fsname=nixhome-pool"
          "dropcacheonclose=true"
        ];
        noCheck = true;
      };
    };

    # 🛒 1. DIE EINKAUFSLISTE (Nachts um 03:00)
    systemd.services.nixhome-mover-prepper = {
      description = "NixHome Mover Prepper: Erstellt Einkaufsliste für Tier C";
      serviceConfig.Type = "oneshot";
      script = ''
        SRC="/mnt/fast-data"
        AGE=14
        echo "📝 Erstelle Einkaufsliste (Dateien > $AGE Tage)..."
        ${pkgs.findutils}/bin/find "$SRC" -type f -atime +$AGE -printf '%A@ %p\n' | sort -n | cut -d' ' -f2- > ${queueFile}
        echo "✅ Einkaufsliste mit $(wc -l < ${queueFile}) Dateien erstellt."
      '';
    };

    systemd.timers.nixhome-mover-prepper = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "03:00"; Persistent = true; };
    };

    # 🚚 2. DER INTELLIGENTE MOVER (Opportunistisch)
    systemd.services.nixhome-mover = {
      description = "NixHome Intelligent Mover: Führt Migration bei Gelegenheit durch";
      serviceConfig.Type = "oneshot";
      script = ''
        set -euo pipefail
        SRC="/mnt/fast-data"
        DST="/mnt/archive"
        HDD_DEV="/dev/disk/by-label/tier-c"
        
        WARN_LIMIT=80
        CRITICAL_LIMIT=90
        TARGET_LEVEL=60

        get_usage() { ${pkgs.coreutils}/bin/df --output=pcent "$1" | tail -1 | tr -dc '0-9'; }
        is_spinning() { ${pkgs.hdparm}/bin/hdparm -C "$1" 2>/dev/null | grep -q "active/idle"; }
        is_busy() { 
          # Prüft ob die HDD gerade I/O Last hat (wichtig: Film schauen = busy)
          [[ $(${pkgs.procps}/bin/iostat -dx "$1" 1 2 | tail -n 2 | head -n 1 | awk '{print $14}') != "0.00" ]]
        }

        USAGE=$(get_usage "$SRC")
        
        # --- KRITISCHER FALL ---
        if [ "$USAGE" -gt "$CRITICAL_LIMIT" ]; then
          echo "🚨 KRITISCH ($USAGE%): Verschiebe sofort bis $TARGET_LEVEL%!"
          # Wenn Liste leer, erstelle schnell eine frische
          if [ ! -s ${queueFile} ]; then
            ${pkgs.findutils}/bin/find "$SRC" -type f -printf '%A@ %p\n' | sort -n | cut -d' ' -f2- > ${queueFile}
          fi
          # Migration erzwingen
          cat ${queueFile} | while read -r file; do
            [ $(get_usage "$SRC") -le "$TARGET_LEVEL" ] && break
            [ -f "$file" ] && mv -v "$file" "$DST/"
          done
          truncate -s 0 ${queueFile}
          exit 0
        fi

        # --- OPPORTUNISTISCHER FALL ---
        if [ "$USAGE" -gt "$WARN_LIMIT" ]; then
          if [ -s ${queueFile} ]; then
            if is_spinning "$HDD_DEV"; then
              if ! is_busy "$HDD_DEV"; then
                echo "⚖️ Gelegenheit erkannt! HDD ist an und Idle. Verarbeite Einkaufsliste..."
                cat ${queueFile} | while read -r file; do
                  [ $(get_usage "$SRC") -le "$TARGET_LEVEL" ] && break
                  # Wenn die Platte plötzlich busy wird (Nutzer startet Film), abbrechen!
                  if is_busy "$HDD_DEV"; then
                    echo "⚠️ HDD wird plötzlich genutzt. Breche Migration ab, um Nutzer nicht zu stören."
                    break
                  fi
                  [ -f "$file" ] && mv -v "$file" "$DST/"
                done
                # Liste aktualisieren (nur verbliebene behalten)
                ${pkgs.findutils}/bin/find "$SRC" -type f -atime +14 -printf '%A@ %p\n' | sort -n | cut -d' ' -f2- > ${queueFile}
              else
                echo "⏳ HDD ist an, aber beschäftigt (Film läuft?). Mover wartet auf Idle."
              fi
            else
              echo "💤 HDD schläft. Mover wartet auf Spin-up durch Nutzer."
            fi
          else
            echo "✅ Keine Dateien in der Einkaufsliste."
          fi
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
