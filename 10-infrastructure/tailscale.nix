/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Tailscale Mesh VPN
 * TRACE-ID:     NIXH-INF-021
 * PURPOSE:      Zero-Config VPN für sicheren Remote-Zugriff.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
  };
}
