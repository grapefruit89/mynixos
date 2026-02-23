{ config, lib, pkgs, ... }:

{
  # ── FIREWALL ───────────────────────────────────────────────────────────────
  # Standardmäßig alles blockieren, nur explizit erlaubte Ports öffnen.
  networking.firewall.enable = true;

  # Standardmäßig erlauben wir 80 und 443 global für Traefik.
  networking.firewall.allowedTCPPorts = [
    80  # Traefik Web
    443 # Traefik WebSecure
  ];

  # SSH (Port 53844) nur von Tailscale und internen Netzwerken erlauben.
  # Dies macht SSH vom externen Internet aus unsichtbar.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 53844 ]; # Erlaube SSH über Tailscale

  # LAN ohne Interface-Hardcode: RFC1918-Netze erlauben
  networking.firewall.extraInputRules = ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport { 53844 } accept
  '';

  networking.firewall.allowedUDPPorts = [
    41641 # Tailscale
  ];
}
