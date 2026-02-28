/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Radarr Movie Manager
 * TRACE-ID:     NIXH-SRV-014
 * PURPOSE:      Automatisches Management von Filmen.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "radarr";
  port = config.my.ports.radarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/radarr";
}) args
