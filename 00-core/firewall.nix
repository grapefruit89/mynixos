{ lib, ... }:
{
  networking.firewall.enable = true;

  # Global nur HTTP/HTTPS fuer Traefik.
  networking.firewall.allowedTCPPorts = lib.mkForce [ 80 443 ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];

  # SSH 53844 explizit ueber Tailscale-Interface erlauben.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ 53844 ];

  # SSH 53844 nur aus internen Netzen inkl. Tailscale-CGNAT.
  networking.firewall.extraInputRules = lib.mkForce ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport 53844 accept

    # AdGuard DNS fuer LAN + Tailscale (53/tcp+udp), aber nicht oeffentlich.
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport 53 accept
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } udp dport 53 accept
  '';
}
