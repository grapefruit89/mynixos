/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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
 *   checksum: sha256:d3ed06f9f098491adc6557ac0d4d43af99670e5d7a590b4945d09c7692aee74d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
