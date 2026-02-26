{ ... }:
{
  imports = [
    ./hosts/q958/hardware-configuration.nix
    ./hosts/q958/hardware-profile.nix      # <-- Neu: Hardware-Cockpit

    # 00 — Core (Die Schaltzentrale)
    ./00-core/registry.nix      # <-- Neu: Feature-Toggles
    ./00-core/configs.nix
    ./00-core/network.nix       # <-- Neu: systemd-networkd + Avahi
    ./00-core/killswitch.nix    # <-- Neu: VPN Killswitch
    ./00-core/user-preferences.nix
    ./00-core/principles.nix
    ./00-core/logging.nix
    ./00-core/locale.nix
    ./00-core/ports.nix
    ./00-core/host.nix
    ./00-core/secrets.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/system.nix
    ./00-core/shell.nix
    ./00-core/fail2ban.nix
    ./automation.nix
    ./00-core/home-manager.nix

    # 10 — Infrastructure
    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik-core.nix
    ./10-infrastructure/traefik-routes-internal.nix
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/wireguard-vpn.nix

    # 20 — Services
    ./20-services/media/default.nix
    ./20-services/media/media-stack.nix
    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/paperless.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix

    # 90 — Policy
    # ./90-policy/security-assertions.nix
  ];

  system.stateVersion = "25.11";

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];
}
