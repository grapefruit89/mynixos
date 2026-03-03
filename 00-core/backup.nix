{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-002";
    title = "Backup (Restic Expert)";
    description = "Secure Restic backup logic with automated integrity checks and cloud sync.";
    layer = 00;
    nixpkgs.category = "services/backup";
    capabilities = [ "backup/restic" "cloud/sync" "security/integrity-check" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  localRepo = "/mnt/archive/.restic-vault";
  maxSizeGB = 15;
in
{
  options.my.meta.backup = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for backup module";
  };


  config = lib.mkIf config.my.services.backup.enable {
    services.restic.backups.daily = {
      initialize = true;
      repository = localRepo;
      passwordFile = "/etc/secrets/restic-password";
      
      paths = [
        "/data/state"
        "/data/metadata"
        "/etc/nixos"
        "/var/lib/pocket-id"
      ];

      createWrapper = true;
      runCheck = true;
      checkOpts = [ "--with-cache" ];
      extraOptions = [ "--exclude-caches" ];

      backupPrepareCommand = ''
        DATA_SIZE=$(${pkgs.coreutils}/bin/du -sb /data/state /data/metadata /etc/nixos | ${pkgs.gawk}/bin/awk '{sum+=$1} END {print sum}')
        LIMIT=$(( ${toString maxSizeGB} * 1024 * 1024 * 1024 ))
        if [ "$DATA_SIZE" -gt "$LIMIT" ]; then
          echo "🚨 BACKUP ABGEBROCHEN: Limit überschritten!"
          exit 1
        fi
      '';

      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };

    systemd.services.restic-cloud-sync = {
      description = "Sync Restic Vault to Cloud";
      after = [ "restic-backups-daily.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} cloud-backup:nixhome-vault --bwlimit 5M";
        ExecCondition = "${pkgs.systemd}/bin/systemctl is-active --quiet restic-backups-daily.service";
      };
    };

    environment.systemPackages = with pkgs; [ restic rclone ];
  };
}
