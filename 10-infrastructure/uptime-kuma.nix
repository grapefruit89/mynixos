/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-10-NET-INFRA-016
 *   title: "Uptime Kuma"
 *   layer: 10
 *   req_refs: [REQ-INF]
 *   status: stable
 * traceability:
 *   parent: NIXH-10-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:0f28b214ce57c9bdb8a5e5cb092fcec0549595a201bd4b9f4a89ed8bb59d4778"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
 */

{ ... }:
{
  services.uptime-kuma.enable = true;
}
