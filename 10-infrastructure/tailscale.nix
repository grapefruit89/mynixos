/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-015
 *   title: "Tailscale"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:0e6dafd39808a1b0d9918a31e8f9f350a87b8a52819440172d510305fe895c82
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
