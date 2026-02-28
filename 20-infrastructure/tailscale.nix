/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Tailscale
 * TRACE-ID:     NIXH-INF-019
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:7229a4df618df1c89ed9b8d834fa361e953157cfe222e939b1a0677b18b42c70
 */

{ ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
  };
}
