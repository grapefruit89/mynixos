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
 *   checksum: sha256:ff40b802ca3e9e7bb4301719da1877019aef15e8abcb69206f1b2da7c512461d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
