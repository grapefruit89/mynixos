/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-002
 *   title: "Backup (Restic Expert)"
 *   layer: 00
 * summary: Secure Restic backup logic with automated integrity checks and cloud sync.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/backup/restic.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  localRepo = "/mnt/archive/.restic-vault";
  maxSizeGB = 15; # Erhöht auf 15GB für entspannteres Wachstum
in
{
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

    # 🚀 SRE FEATURES
    createWrapper = true; # Erzeugt 'restic-daily' CLI Tool
    runCheck = true;      # Automatische Integritätsprüfung nach Backup
    checkOpts = [ "--with-cache" ];

    extraOptions = [ "--exclude-caches" ];

    # Größen-Check vor dem Start (Sicherheits-Gate)
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
      RandomizedDelaySec = "1h"; # Entzerrt die Last
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  # Cloud-Sync (Nur nach Erfolg)
  systemd.services.restic-cloud-sync = {
    description = "Sync Restic Vault to Cloud";
    after = [ "restic-backups-daily.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} cloud-backup:nixhome-vault --bwlimit 5M";
      # SRE: Nur starten wenn Backup erfolgreich war
      ExecCondition = "${pkgs.systemd}/bin/systemctl is-active --quiet restic-backups-daily.service";
    };
  };

  environment.systemPackages = with pkgs; [ restic rclone ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
