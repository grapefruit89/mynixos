/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Uptime Kuma
 * TRACE-ID:     NIXH-INF-022
 * PURPOSE:      Service-Uptime Monitoring & Alarming.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ ... }:
{
  services.uptime-kuma.enable = true;
}
