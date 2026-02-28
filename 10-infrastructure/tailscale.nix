/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-015
 *   title: "Tailscale"
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
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
  };
}





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8e98a40d12d520d95b9cfa75272eed9686cfbe41c51d530952e46fb0741b04de
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
