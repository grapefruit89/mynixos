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

  # SSH (Port 22) nur von Tailscale und internen Netzwerken erlauben.
  # Dies macht SSH vom externen Internet aus unsichtbar.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ]; # Erlaube SSH über Tailscale
  networking.firewall.interfaces.eth0.allowedTCPPorts = [ 22 ];    # Erlaube SSH von LAN (RFC1918, z.B. 192.168.x.x)

  networking.firewall.allowedUDPPorts = [
    41641 # Tailscale
  ];
}
