/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Traefik Aggregator
 * TRACE-ID:     NIXH-INF-005
 * PURPOSE:      Bündelung aller Traefik-Module (Core, Dynamisch, Intern).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [10-infra/traefik-core.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ ... }:
{
  imports = [
    ./traefik-core.nix
    ./traefik-routes-internal.nix
  ];
}
