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
{ config, lib, ... }:
{
  # 🚀 TAILSCALE EXHAUSTION
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "client";
    
    # SRE: Automatisierung & Redundanz
    extraUpFlags = [
      "--ssh"                # Aktiviert Tailscale SSH
      "--accept-dns=true"
      "--accept-routes=true"
    ];

    # 🔐 CADDY INTEGRATION (Extreme SRE)
    # Erlaubt Caddy, Zertifikate direkt vom Tailscale-Daemon zu beziehen.
    permitCertUid = config.services.caddy.user;
  };

  # systemd Hardening
  systemd.services.tailscaled.serviceConfig = {
    Restart = "always";
    RestartSec = "2s";
    OOMScoreAdjust = -1000;
  };
}



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:fcc6abed4b0404a1e388cb36dc848181b2fe5c1c63b265ff414bb6707dd1aede
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
