/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Fail2Ban Intrusion Prevention
 * TRACE-ID:     NIXH-CORE-014
 * PURPOSE:      Brute-Force Schutz für SSH & Caddy-Auth via NFTables.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, pkgs, ... }:
let
  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in
{
  services.fail2ban = {
    enable = true;

    # Internal/private ranges should never be banned.
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ] ++ lanCidrs ++ tailnetCidrs;

    bantime = "1h";
    maxretry = 5;

    jails.sshd.settings = {
      enabled = true;
      port = sshPort;
      mode = "aggressive";
      findtime = "10m";
      bantime = "1h";
      maxretry = 5;
    };

    # Caddy / HTTP Brute Force Protection
    jails.caddy-auth = {
      settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-auth";
        logpath = "/var/log/caddy/access.log";
        backend = "auto";
        maxretry = 5;
        findtime = "5m";
        bantime = "24h";
      };
    };
  };

  # Filter Definition für Caddy (JSON Logs)
  environment.etc."fail2ban/filter.d/caddy-auth.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<ADDR>".*"status":401.*$
                ^.*"remote_ip":"<ADDR>".*"status":403.*$
    journalmatch = _SYSTEMD_UNIT=caddy.service
  '';
}
