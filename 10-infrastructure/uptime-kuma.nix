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
 *   checksum: sha256:786fe0f37cef312304a6e32bdff12cba454395e68d3f041ca20a4326ea8f9950
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
