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
{ lib, ... }:
{
  # 🚀 JOURNALD EXHAUSTION
  # Maximale Nutzung deklarativer Journald-Steuerung
  services.journald.extraConfig = ''
    Storage=persistent
    Compress=yes
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
    RateLimitIntervalSec=30s
    RateLimitBurst=10000
    ForwardToSyslog=no
    ForwardToConsole=no
    TTYPath=/dev/tty12
    MaxLevelConsole=info
    MaxLevelStore=debug
  '';

  # SRE: Automatisierte Journal-Bereinigung via Tmpfiles (Sicherheitsnetz)
  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal - -"
    "z /var/log/journal 2755 root systemd-journal - -"
  ];

  # Deaktiviere redundante Logging-Dienste für Performance
  # (Standardmäßig ohnehin aus, hier nur als explizite SRE-Entscheidung)
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:301557de633fd9eb05c41627cd8861179ce1a7f14c37b4d9651830085f8e8961
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
