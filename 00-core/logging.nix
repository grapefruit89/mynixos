/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-014
 *   title: "Logging"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   status: audited
 * ---
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:730286e98aed8171816620420a2aa10830289461ca874b281a802c85de85b75b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
