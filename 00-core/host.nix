/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Host Identity
 * TRACE-ID:     NIXH-CORE-020
 * PURPOSE:      Festlegung des Hostnamens basierend auf zentralen Konfigurationen.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, lib, ... }:
{
  # source-id: CFG.identity.host
  networking.hostName = lib.mkForce config.my.configs.identity.host;
}
