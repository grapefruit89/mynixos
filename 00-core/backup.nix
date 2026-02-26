# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Restic Backup (Tier A / App-Daten)

{ config, lib, pkgs, ... }:
{
  # ── RESTIC CONFIGURATION ──────────────────────────────────────────────────
  # Sichert Anwendungs-Datenbanken und wichtige Configs
  services.restic.backups.daily = {
    initialize = true;
    
    # Lokaler Target-Pfad (z.B. auf einer dedizierten Backup-HDD)
    # HINWEIS: Hier dein Backup-Ziel anpassen!
    repository = "/mnt/backup/restic";
    
    # Passwort-Datei (sink: encrypted backups)
    passwordFile = "/etc/secrets/restic-password";
    
    # Pfade die gesichert werden sollen (Tier A / NVMe)
    paths = [
      "/data/state"      # Datenbanken & App-States
      "/etc/nixos"       # Konfiguration
    ];

    # Timer: Täglich um 02:00 AM
    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };

    # Behalte nur die letzten 7 Tage, 4 Wochen, 6 Monate
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  # Stelle sicher, dass restic installiert ist
  environment.systemPackages = [ pkgs.restic ];
}
