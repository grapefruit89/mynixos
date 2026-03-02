/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-007
 *   title: "Fail2ban (SRE Aggressive)"
 *   layer: 00
 * summary: Aggressive brute-force protection with escalations and nftables backend.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/fail2ban.nix
 * ---
 */
{ config, pkgs, lib, ... }:
let
  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in
{
  # 🚀 FAIL2BAN SRE STANDARD
  services.fail2ban = {
    enable = true;
    
    # ── NFTABLES BACKEND (Modern) ─────────────────────────────────────────
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";

    # ── GLOBAL WHITELIST ──────────────────────────────────────────────────
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ] ++ lanCidrs ++ tailnetCidrs;

    # ── ESKALIERENDE BAN-ZEITEN ───────────────────────────────────────────
    # Wer wiederholt angreift, wird exponentiell länger gesperrt.
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64"; 
      maxtime = "168h"; # Max 1 Woche Isolation
      overalljails = true; 
    };
    
    maxretry = 5;

    # ── JAILS ─────────────────────────────────────────────────────────────
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

      # Caddy / HTTP Brute Force Protection (RAM Journal Source)
      caddy-auth = {
        settings = {
          enabled = true;
          port = "http,https";
          filter = "caddy-auth";
          backend = "systemd";
          maxretry = 5;
          findtime = "5m";
          bantime = "24h";
        };
      };
    };
  };

  # ── CUSTOM FILTERS ──────────────────────────────────────────────────────
  environment.etc."fail2ban/filter.d/caddy-auth.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<ADDR>".*"status":401.*$
                ^.*"remote_ip":"<ADDR>".*"status":403.*$
    journalmatch = _SYSTEMD_UNIT=caddy.service
  '';

  # ── PERFORMANCE HARDENING ───────────────────────────────────────────────
  systemd.services.fail2ban.serviceConfig = {
    OOMScoreAdjust = 500;
    ProtectSystem = "strict";
    ReadWritePaths = [ "/var/lib/fail2ban" "/var/run/fail2ban" ];
    PrivateTmp = true;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
