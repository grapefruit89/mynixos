/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        PocketID Authentication
 * TRACE-ID:     NIXH-INF-003
 * PURPOSE:      Zentraler OIDC-Identitätsprovider für Single-Sign-On (SSO).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = "https://auth.${domain}";
        title = "m7c5 Login";
      };
    };

    systemd.services.pocket-id = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
        # Health-Endpoint für Caddy
        ExecStartPost = "${pkgs.coreutils}/bin/sleep 2";
      };
    };

    services.caddy.virtualHosts."auth.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}
