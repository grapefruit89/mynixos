{ lib, ... }:
{
  # ── FIREWALL ─────────────────────────────────────────────────────────────
  networking.firewall.enable = true;

  # Öffentlich nur Traefik + SSH
  networking.firewall.allowedTCPPorts = [ 80 443 53844 ];

  # SSH nur über Tailscale und LAN (RFC1918)
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ 53844 ];
  networking.firewall.extraInputRules = lib.mkForce ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport 53844 accept
  '';
}
