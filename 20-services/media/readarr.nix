/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Readarr Book Manager
 * TRACE-ID:     NIXH-SRV-012
 * PURPOSE:      Automatisches Management von Büchern.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-services/media/_lib.nix]
 * LAYER:        20-services
 * STATUS:       Stable
 */

{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "readarr";
      port = config.my.ports.readarr;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/readarr";
    })
  ];
}
