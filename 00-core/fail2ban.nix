/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-007
 *   title: "Fail2ban"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:e7558017a83d356a1fa8197c77b345d86dd8c0398f20ec232ab3fab9730d4b16
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
