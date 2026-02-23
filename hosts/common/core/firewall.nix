{ config, lib, pkgs, ... }:

{
  # ── FIREWALL ───────────────────────────────────────────────────────────────
  # Standardmäßig alles blockieren, nur explizit erlaubte Ports öffnen.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = lib.mkForce [
    53844 # SSH (persönlicher Standard, gesichert mit mkForce)
    80 # Traefik Web
    443 # Traefik WebSecure
  ];
  networking.firewall.allowedUDPPorts = [
    41641 # Tailscale
  ];
}
