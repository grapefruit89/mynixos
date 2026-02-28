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
{ config, pkgs, lib, ... }:
let
  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in
{
  # 🚀 FAIL2BAN EXHAUSTION
  services.fail2ban = {
    enable = true;
    
    # Globale Einstellungen via Nix Options
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ] ++ lanCidrs ++ tailnetCidrs;

    bantime = "1h";
    bantime.increment = true; # SRE: Eskalierende Ban-Dauer
    
    maxretry = 5;
    daemonConfig = ''
      [DEFAULT]
      dbpurgeage = 1d
    '';

    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = sshPort;
          mode = "aggressive";
          findtime = "10m";
          bantime = "1h";
          maxretry = 3; # Strengere SRE-Policy
        };
      };

      # Caddy / HTTP Brute Force Protection (Deklarativ integriert)
      caddy-auth = {
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
  };

  # Filter Definition via Nix Option (falls verfügbar, sonst etc)
  # NixOS hat leider keine direkt Option für Filter-Definitionen in services.fail2ban
  environment.etc."fail2ban/filter.d/caddy-auth.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<ADDR>".*"status":401.*$
                ^.*"remote_ip":"<ADDR>".*"status":403.*$
    journalmatch = _SYSTEMD_UNIT=caddy.service
  '';

  # Performance Tuning
  systemd.services.fail2ban.serviceConfig.OOMScoreAdjust = 500;
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:90a308f8ab0ebd2c5443bb1dc349fc52461a61047bdf5046ad3f63a4e0c6fb8b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
