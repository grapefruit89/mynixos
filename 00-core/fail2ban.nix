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
  };
}
