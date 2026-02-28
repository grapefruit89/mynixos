/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Pocket Id
 * TRACE-ID:     NIXH-INF-016
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:49aa94cf3d6abe07c9fc56ebca0a745db933c05e03300138c95dd78c0087e618
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
