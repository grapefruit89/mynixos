/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        System Entrypoint
 * TRACE-ID:     NIXH-CORE-000
 * REQ-REF:      REQ-SYS-01
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:76f4c17ecd0ae90765cf54da91c5822470fc08ae8d30e33736d439314eebc7b9
 */
{ lib, pkgs, config, ... }:
{
  imports = [
    ./10-core/boot-safeguard.nix
    ./10-core/ssh-rescue.nix
    ./10-core/kernel-slim.nix
    ./10-core/shell-premium.nix
    ./10-core/tty-info.nix
    <sops-nix/modules/sops>
    ./20-infrastructure/sso.nix
    ./hosts/q958/hardware-configuration.nix
    ./hosts/q958/hardware-profile.nix

    # 00 — Core
    ./10-core/registry.nix
    ./10-core/configs.nix
    ./10-core/config-merger.nix
    ./10-core/nix-tuning.nix
    ./10-core/symbiosis.nix
    ./10-core/system-stability.nix
    ./10-core/secrets.nix
    ./10-core/network.nix
    ./10-core/storage.nix
    ./10-core/backup.nix
    # ./10-core/killswitch.nix # Replaced by netns confinement
    ./10-core/user-preferences.nix
    ./10-core/principles.nix
    ./10-core/logging.nix
    ./10-core/locale.nix
    ./10-core/ports.nix
    ./10-core/host.nix
    ./10-core/users.nix
    ./10-core/ssh.nix
    ./10-core/firewall.nix
    ./10-core/system.nix
    # ./10-core/shell.nix # Replaced by shell-premium.nix
    ./10-core/fail2ban.nix
    ./10-core/ai-tools.nix
    ./30-services/automation.nix
    ./10-core/home-manager.nix

    # 10 — Infrastructure
    ./20-infrastructure/tailscale.nix
    ./20-infrastructure/caddy.nix
    
    ./20-infrastructure/homepage.nix
    ./20-infrastructure/cockpit.nix
    # ./20-infrastructure/wireguard-vpn.nix # Replaced by netns confinement
    ./20-infrastructure/vpn-confinement.nix
    ./20-infrastructure/secret-ingest.nix
    ./20-infrastructure/landing-zone-ui.nix
    ./20-infrastructure/pocket-id.nix
    ./20-infrastructure/dns-automation.nix

    # 20 — Services
    ./30-services/media/default.nix
    ./30-services/media/media-stack.nix
    ./30-services/apps/audiobookshelf.nix
    ./30-services/apps/vaultwarden.nix
    ./30-services/apps/paperless.nix
    ./30-services/apps/miniflux.nix
    ./30-services/apps/n8n.nix
    ./30-services/apps/scrutiny.nix
    ./30-services/apps/filebrowser.nix
    ./30-services/apps/ai-agents.nix
    ./30-services/apps/home-assistant.nix

    # 90 — Policy
    ./90-policy/security-assertions.nix # <-- Aktiviert
    ./90-policy/no-legacy.nix
  ];

  system.stateVersion = "25.11";
  networking.hostName = "nixhome";

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];
}
