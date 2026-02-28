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
 *   checksum: sha256:f0733351e3f2fdc09001086b5fc0ecf53eb9e93a3d878d883591550c6fa4d99e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
