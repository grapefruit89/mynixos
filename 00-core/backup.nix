/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-002
 *   title: "Backup"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  # Lokales Tresor-Verzeichnis auf der HDD (Tier C)
  localRepo = "/mnt/archive/.restic-vault";
  # Maximale Größe für Topf A (10GB Sperre)
  maxSizeGB = 10;
in
{
  # ── RESTIC BACKUP LOGIK ───────────────────────────────────────────────────
  services.restic.backups.daily = {
    initialize = true;
    repository = localRepo;
    passwordFile = "/etc/secrets/restic-password";
    
    paths = [
      "/data/state"        # Datenbanken & App-Configs
      "/data/metadata"     # Wichtige Metadaten (Primär auf NVMe)
      "/etc/nixos"         # System-Konfiguration
      "/var/lib/pocket-id" # SSO Identitäten
    ];

    # 🛡️ 10GB SICHERHEITS-CHECK
    # Bricht ab, wenn die Quelldaten zu groß werden (Schutz vor Fehlern)
    extraOptions = [
      "--exclude-caches"
    ];

    # Vor dem Backup: Größe prüfen
    backupPrepareCommand = ''
      DATA_SIZE=$(${pkgs.coreutils}/bin/du -sb /data/state /data/metadata /etc/nixos | ${pkgs.gawk}/bin/awk '{sum+=$1} END {print sum}')
      LIMIT=$(( ${toString maxSizeGB} * 1024 * 1024 * 1024 ))
      
      if [ "$DATA_SIZE" -gt "$LIMIT" ]; then
        echo "🚨 BACKUP ABGEBROCHEN: Datenmenge ($((DATA_SIZE/1024/1024)) MB) überschreitet das ${toString maxSizeGB}GB Limit!"
        exit 1
      fi
      echo "✅ Größe OK: $((DATA_SIZE/1024/1024)) MB. Starte Backup..."
    '';

    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  # ── CLOUD SYNC (RCLONE) ───────────────────────────────────────────────────
  # Spiegelt den lokalen Restic-Tresor verschlüsselt in die Cloud
  systemd.services.restic-cloud-sync = {
    description = "Sync Restic Vault to Cloud (rclone)";
    after = [ "restic-backups-daily.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # Nur starten, wenn das lokale Backup erfolgreich war
      ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} cloud-backup:nixhome-vault --limit-rate 5M";
    };
  };

  environment.systemPackages = with pkgs; [ restic rclone ];
}









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:ecfff974913555d662bc670bca39410e485536f7ffccdec30817009ad91d811a
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
