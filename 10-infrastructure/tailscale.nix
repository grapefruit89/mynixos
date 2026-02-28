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
{ lib, ... }:
{
  # 🚀 TAILSCALE EXHAUSTION
  services.tailscale = {
    enable = true;
    openFirewall = false; # Via firewall.nix geregelt
    useRoutingFeatures = "client"; # Ermöglicht Exit Nodes etc falls konfiguriert
    
    # SRE: Automatisierung via extraUpFlags
    # Hinweis: In neueren NixOS Versionen gibt es extraUpFlags
    extraUpFlags = [
      "--ssh" # Aktiviert Tailscale SSH für noch mehr Redundanz
      "--accept-dns=true"
      "--accept-routes=true"
    ];
  };

  # systemd Hardening für Tailscale
  systemd.services.tailscaled.serviceConfig = {
    # Tailscale ist kritische Infrastruktur
    Restart = "always";
    RestartSec = "2s";
    OOMScoreAdjust = -1000;
  };
}



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8c52861e36f9e01e1b7e246b16399374839c9d87e82db7cfa2d5f95c014408bc
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
