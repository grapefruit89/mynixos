{ lib, config, ... }:
let
  sshPort = config.my.ports.ssh;
in
{
  networking.firewall.enable = true;

  # Global nur HTTP/HTTPS fuer Traefik.
  networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttp config.my.ports.traefikHttps ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];

  # SSH explizit ueber Tailscale-Interface erlauben.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

  # SSH nur aus internen Netzen inkl. Tailscale-CGNAT.
  networking.firewall.extraInputRules = lib.mkForce ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport ${toString sshPort} accept

    # AdGuard DNS fuer LAN + Tailscale (53/tcp+udp), aber nicht oeffentlich.
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport 53 accept
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } udp dport 53 accept
  '';
}
