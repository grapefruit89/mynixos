/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-016
 *   title: "Uptime Kuma"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:0f28b214ce57c9bdb8a5e5cb092fcec0549595a201bd4b9f4a89ed8bb59d4778
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
