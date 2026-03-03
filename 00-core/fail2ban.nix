{ config, pkgs, lib, ... }:
let
  nms = {
    id = "NIXH-00-CORE-007";
    title = "Fail2ban (SRE Aggressive)";
    description = "Aggressive brute-force protection with specialized Caddy JSON filters.";
    layer = 00;
    nixpkgs.category = "services/security";
    capabilities = [ "security/bruteforce-protection" "network/hardening" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in
{
  options.my.meta.fail2ban = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.fail2ban.enable or true) {
    services.fail2ban = {
      enable = true; banaction = "nftables-multiport"; banaction-allports = "nftables-allports"; ignoreIP = [ "127.0.0.1/8" "::1" ] ++ lanCidrs ++ tailnetCidrs;
      bantime = "1h"; bantime-increment = { enable = true; multipliers = "1 2 4 8 16 32 64"; maxtime = "168h"; overalljails = true; }; maxretry = 5;
      jails = { sshd.settings = { enabled = true; port = sshPort; mode = "aggressive"; }; caddy-auth.settings = { enabled = true; port = "http,https"; filter = "caddy-json"; backend = "systemd"; maxretry = 3; findtime = "5m"; bantime = "24h"; }; caddy-scan.settings = { enabled = true; port = "http,https"; filter = "caddy-scan"; backend = "systemd"; maxretry = 2; findtime = "1m"; bantime = "168h"; }; };
    };
    environment.etc = { "fail2ban/filter.d/caddy-json.conf".text = "[Definition]\nfailregex = ^.*\"remote_ip\":\"<ADDR>\".*\"status\":(401|403).*$\njournalmatch = _SYSTEMD_UNIT=caddy.service"; "fail2ban/filter.d/caddy-scan.conf".text = "[Definition]\nfailregex = ^.*\"remote_ip\":\"<ADDR>\".*\"uri\":\".*(?:/\\.git|/\\.env|/wp-admin|/wp-login\\.php|/xmlrpc\\.php)\".*\"status\":404.*$\njournalmatch = _SYSTEMD_UNIT=caddy.service"; };
    systemd.services.fail2ban.serviceConfig = { OOMScoreAdjust = 500; ProtectSystem = "strict"; ReadWritePaths = [ "/var/lib/fail2ban" "/var/run/fail2ban" ]; PrivateTmp = true; };
  };
}
