/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Prowlarr Indexer Manager
 * TRACE-ID:     NIXH-SRV-013
 * PURPOSE:      Zentrales Indexer-Management für die Arr-Suite.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

args@{ lib, config, pkgs, ... }:
((import ./_lib.nix { inherit lib pkgs; }) {
  name = "prowlarr";
  port = config.my.ports.prowlarr;
  stateOption = "dataDir";
  defaultStateDir = "/var/lib/prowlarr";
  supportsUserGroup = false;
}) args
