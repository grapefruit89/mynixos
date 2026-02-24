{ config, ... }:
let
  sshPort = toString config.my.ports.ssh;
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
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      "100.64.0.0/10"
    ];

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
