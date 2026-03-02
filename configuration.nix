/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-SYS-ROOT-001
 *   title: "System Entrypoint"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-SYS-01]
 *   upstream: []
 *   downstream: [NIXH-00-SYS-CORE-ALL]
 *   status: audited
 * ---
 */
{ lib, pkgs, config, inputs, ... }:
{
  imports = [
    ./00-core/defaults.nix
    ./00-core/boot-safeguard.nix
    ./00-core/ssh-rescue.nix
    ./00-core/kernel-slim.nix
    ./00-core/shell-premium.nix
    ./00-core/tty-info.nix
    inputs.sops-nix.nixosModules.sops
    ./10-infrastructure/sso.nix
    ./00-core/host-q958-hardware-configuration.nix
    ./00-core/host-q958-hardware-profile.nix

    # 00 — Core
    ./00-core/registry.nix
    ./00-core/configs.nix
    ./00-core/config-merger.nix
    ./00-core/nix-tuning.nix
    ./00-core/symbiosis.nix
    ./00-core/zram-swap.nix
    ./00-core/system-stability.nix
    ./00-core/secrets.nix
    ./00-core/network.nix
    ./00-core/storage.nix
    ./00-core/backup.nix
    # ./00-core/killswitch.nix # Replaced by netns confinement
    ./00-core/user-preferences.nix
    ./00-core/principles.nix
    ./00-core/logging.nix
    ./00-core/locale.nix
    ./00-core/ports.nix
    ./00-core/host.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/system.nix
    # ./00-core/shell.nix # Replaced by shell-premium.nix
    ./00-core/fail2ban.nix
    ./00-core/ai-tools.nix
    ./20-services/automation.nix
    ./00-core/home-manager.nix

    # 10 — Infrastructure
    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/caddy.nix
    ./10-infrastructure/adguardhome.nix
    ./10-infrastructure/netdata.nix
    ./10-infrastructure/cloudflared-tunnel.nix
    ./10-infrastructure/valkey.nix
    ./10-infrastructure/postgresql.nix
    
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/cockpit.nix
    # ./10-infrastructure/wireguard-vpn.nix # Replaced by netns confinement
    ./10-infrastructure/vpn-confinement.nix
    ./10-infrastructure/secret-ingest.nix
    ./10-infrastructure/landing-zone-ui.nix
    ./10-infrastructure/pocket-id.nix
    ./10-infrastructure/dns-automation.nix
    ./10-infrastructure/olivetin.nix

    # 20 — Services
    ./20-services/service-media-default.nix
    ./20-services/service-media-media-stack.nix
    ./20-services/service-app-audiobookshelf.nix
    ./20-services/service-app-vaultwarden.nix
    ./20-services/service-app-paperless.nix
    ./20-services/service-app-miniflux.nix
    ./20-services/service-app-n8n.nix
    ./20-services/service-app-scrutiny.nix
    ./20-services/service-app-filebrowser.nix
    ./20-services/service-app-ai-agents.nix
    ./20-services/service-app-home-assistant.nix
    ./20-services/service-app-zigbee-stack.nix
    ./20-services/service-app-karakeep.nix
    ./20-services/service-app-matrix-conduit.nix

    # 90 — Policy
    ./90-policy/security-assertions.nix # <-- Aktiviert
    ./90-policy/no-legacy.nix
    ./90-policy/binary-only.nix
    ./90-policy/flat-layout.nix
  ];

  system.stateVersion = "25.11";
  networking.hostName = "nixhome";

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 4096; }
  ];
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:ab22b089e803aad01f611d8cd3fbe5c8116ae046acd5c10d2253347b832ff531
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
