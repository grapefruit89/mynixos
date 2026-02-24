{ ... }:
{
  # source: services.uptime-kuma.enable
  # sink:   uptime-kuma systemd service (traefik route handled separately if configured)
  services.uptime-kuma.enable = true;
}
