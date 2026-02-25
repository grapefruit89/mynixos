# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: centralized journald policy (persistent, no per-service file logs)

{ ... }:
{
  services.journald.extraConfig = "Storage=persistent
SystemMaxUse=500M
SystemMaxFileSize=50M
MaxRetentionSec=7day
";

  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal - -"
  ];
}
