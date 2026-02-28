/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        DDNS Updater
 * TRACE-ID:     NIXH-INF-020
 * PURPOSE:      Automatisches Update der IP-Adresse bei Cloudflare & Co.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable (Inactive)
 */

{ config, ... }:
let
  domain = config.my.configs.identity.domain;
  port = config.my.ports.ddnsUpdater;
in
{
  services.ddns-updater = {
    enable = true;
    environment = {
      LISTENING_ADDRESS = ":${toString port}";
      PERIOD = "10m";
    };
  };

  services.caddy.virtualHosts."nix-ddns.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
