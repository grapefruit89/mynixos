# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: SSH nur aus Heimnetzen/Tailnet, niemals offen ins Internet

{ lib, config, ... }:
let
  sshPort = config.my.ports.ssh;
in
{
  networking.firewall.enable = true;

  # [SEC-NET-EDGE-001] Global inbound bleibt minimal: nur HTTPS.
  networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];

  # [SEC-NET-SSH-002] SSH explizit über Tailscale Interface.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

  # [SEC-NET-SSH-001]/[SEC-NET-SSH-002] SSH und DNS nur aus Heimnetzen + Tailscale-CGNAT.
  networking.firewall.extraInputRules = lib.mkForce ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport ${toString sshPort} accept

    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } tcp dport 53 accept
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10 } udp dport 53 accept
  '';
}
