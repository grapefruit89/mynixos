{ lib, config, ... }:
let
  sshPort = config.my.ports.ssh;
in
{
  networking.firewall.enable = true;

  # Edge policy: global inbound is HTTPS only.
  networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];

  # SSH explicit over tailscale interface only.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

  # LAN/Tailscale scoped exceptions only.
  networking.firewall.extraInputRules = lib.mkForce ''
    # SSH from trusted private ranges (incl. Tailscale CGNAT)
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport ${toString sshPort} accept

    # AdGuard DNS for LAN + Tailscale only (not global)
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport 53 accept
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } udp dport 53 accept
  '';
}
