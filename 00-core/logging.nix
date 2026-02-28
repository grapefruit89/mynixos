/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Journald Logging Policy
 * TRACE-ID:     NIXH-CORE-028
 * PURPOSE:      Zentrale Logging-Retention & Persistenz-Einstellungen.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ ... }:
{
  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
  '';

  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal - -"
  ];
}
