/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Media Module Aggregator
 * TRACE-ID:     NIXH-SRV-030
 * PURPOSE:      Import-Liste aller Media-Module.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ ... }:
{
  imports = [
    ./services-common.nix
    ./arr-wire.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./sonarr.nix
    ./radarr.nix
    ./readarr.nix
    ./prowlarr.nix
    ./sabnzbd.nix
  ];
}
