/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Sonarr Series Manager
 * TRACE-ID:     NIXH-SRV-015
 * PURPOSE:      Automatisches Management von Serien.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "sonarr";
  port = config.my.ports.sonarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/sonarr";
}) args
