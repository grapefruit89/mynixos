/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Cockpit Admin UI
 * TRACE-ID:     NIXH-INF-019
 * PURPOSE:      Web-basiertes Systemmanagement & Monitoring.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.cockpit;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.cockpit;
in
{
  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      port = port;
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
        };
      };
    };

    services.caddy.virtualHosts."admin.${domain}" = {
      extraConfig = ''
        import sso_auth
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}
