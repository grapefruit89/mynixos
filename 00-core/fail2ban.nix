# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: fail2ban Modul

{ config, ... }:
let
  sshPort = toString config.my.ports.ssh;
  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;
  # source-id: CFG.network.tailnetCidrs
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in
{
  # source: /etc/secrets/* is not needed; fail2ban reads auth failures from journal.
  # sink: protects sshd on my.ports.ssh with nftables bans.
  services.fail2ban = {
    enable = true;

    # Internal/private ranges should never be banned by brute-force heuristics.
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ] ++ lanCidrs ++ tailnetCidrs;

    bantime = "1h";
    maxretry = 5;

    # Traceability: this jail is intentionally tied to the single SSH port registry.
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
