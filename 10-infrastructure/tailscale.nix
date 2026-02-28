/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
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
 *   checksum: sha256:8ae59890a25eb72617bf75a542b1265bdacba03fc39835ca278f1046dca55471
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
