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
  # 🚀 FAIL2BAN EXHAUSTION (v2.3 SRE Standard)
  services.fail2ban = {
    enable = true;
    
    # Moderne Firewall-Backend (nftables statt iptables)
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";

    # Globale Whitelist (SRE: Keine Selbst-Aussperrung)
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ] ++ lanCidrs ++ tailnetCidrs;

    # 📈 ESKALIERENDE BAN-ZEITEN (NixOS Native Options)
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64"; # Verdopplung bei jedem Vergehen
      maxtime = "168h"; # Max 1 Woche
      overalljails = true; # IP-Historie gilt über alle Jails hinweg
    };
    
    maxretry = 5;

    # 🗄️ DATABASE MANAGEMENT
    daemonConfig = ''
      [DEFAULT]
      dbpurgeage = 14d
      dbmaxmatches = 1000
    '';

    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = sshPort;
          mode = "aggressive";
          findtime = "10m";
          bantime = "1h";
          maxretry = 3;
        };
      };

      # Caddy / HTTP Brute Force Protection
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

  # Filter Definition via etc-Filesystem (Da keine Nix-Option für Custom Filter existiert)
  environment.etc."fail2ban/filter.d/caddy-auth.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<ADDR>".*"status":401.*$
                ^.*"remote_ip":"<ADDR>".*"status":403.*$
    journalmatch = _SYSTEMD_UNIT=caddy.service
  '';

  # SRE: Performance & Reliability Hardening
  systemd.services.fail2ban.serviceConfig = {
    OOMScoreAdjust = 500; # Darf vor dem Kernel/SSH sterben
    ProtectSystem = "strict";
    ReadWritePaths = [ "/var/lib/fail2ban" "/var/run/fail2ban" ];
    PrivateTmp = true;
  };
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:2eda731623f9ca44c259243af78ce2125f1bea1d6430b68cc1ee397b45154efb
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
