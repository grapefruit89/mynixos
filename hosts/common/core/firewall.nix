{ ... }:

{
  # ── FIREWALL ───────────────────────────────────────────────────────────────
  # Standardmäßig alles blockieren, nur explizit erlaubte Ports öffnen.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    80 # Traefik Web
    443 # Traefik WebSecure
  ];
  networking.firewall.allowedUDPPorts = [
    41641 # Tailscale
  ];
}
