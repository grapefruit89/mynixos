/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-016
 *   title: "Uptime Kuma"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ ... }:
{
  services.uptime-kuma.enable = true;
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:585af1e198ec44a921271103a16b664c6cd5865bf5cb754ddfc8906704f7553d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
