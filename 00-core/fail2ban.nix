/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-007
 *   title: "Fail2ban (SRE Aggressive)"
 *   layer: 00
 * summary: Aggressive brute-force protection with specialized Caddy JSON filters.
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
  services.fail2ban = {
    enable = true;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allports";

    ignoreIP = [ "127.0.0.1/8" "::1" ] ++ lanCidrs ++ tailnetCidrs;

    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64"; 
      maxtime = "168h";
      overalljails = true; 
    };
    
    maxretry = 5;

    jails = {
      sshd.settings = {
        enabled = true;
        port = sshPort;
        mode = "aggressive";
      };

      # ── CADDY AUTH JAIL (RAM Journal Source) ───────────────────────────
      caddy-auth.settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-json";
        backend = "systemd";
        maxretry = 3;
        findtime = "5m";
        bantime = "24h";
      };

      # ── CADDY SCANNER JAIL (Anti-Bot) ──────────────────────────────────
      caddy-scan.settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-scan";
        backend = "systemd";
        maxretry = 2;
        findtime = "1m";
        bantime = "168h"; # 1 Woche Bann für Scanner
      };
    };
  };

  # ── CUSTOM FILTERS (SRE Optimized for Caddy JSON) ────────────────────────
  environment.etc = {
    # Erkennt fehlgeschlagene Logins (401/403)
    "fail2ban/filter.d/caddy-json.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
      journalmatch = _SYSTEMD_UNIT=caddy.service
    '';

    # Erkennt Bot-Scanner (Sucht nach .env, wp-admin, etc.)
    "fail2ban/filter.d/caddy-scan.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<ADDR>".*"uri":".*(?:/\.git|/\.env|/wp-admin|/wp-login\.php|/xmlrpc\.php)".*"status":404.*$
      journalmatch = _SYSTEMD_UNIT=caddy.service
    '';
  };

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
