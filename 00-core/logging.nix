/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-014
 *   title: "Logging"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:70b630be5c9fb5f90cca54c7dc8356f0b07f3e2740e894391d2dea092c1c607b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
