/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-10-NET-INFRA-015
 *   title: "Tailscale"
 *   layer: 10
 *   req_refs: [REQ-INF]
 *   status: stable
 * traceability:
 *   parent: NIXH-10-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:0e6dafd39808a1b0d9918a31e8f9f350a87b8a52819440172d510305fe895c82"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
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
