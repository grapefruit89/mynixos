/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Valkey In-Memory DB
 * TRACE-ID:     NIXH-INF-023
 * PURPOSE:      Hochperformante In-Memory Datenbank (Redis Fork) für interne Dienste.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ pkgs, lib, ... }:
{
  services.redis = {
    package = pkgs.valkey;

    servers.valkey = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
      openFirewall = false;
    };
  };
}
