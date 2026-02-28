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
{ lib, pkgs, config, ... }:
{
  imports = [
    ./00-core/boot-safeguard.nix
    ./00-core/ssh-rescue.nix
    ./00-core/kernel-slim.nix
    ./00-core/shell-premium.nix
    ./00-core/tty-info.nix
    <sops-nix/modules/sops>
    ./10-infrastructure/sso.nix
    ./hosts/q958/hardware-configuration.nix
    ./hosts/q958/hardware-profile.nix

    # 00 — Core
    ./00-core/registry.nix
    ./00-core/configs.nix
    ./00-core/config-merger.nix
    ./00-core/nix-tuning.nix
    ./00-core/symbiosis.nix
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
    
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/cockpit.nix
    # ./10-infrastructure/wireguard-vpn.nix # Replaced by netns confinement
    ./10-infrastructure/vpn-confinement.nix
    ./10-infrastructure/secret-ingest.nix
    ./10-infrastructure/landing-zone-ui.nix
    ./10-infrastructure/pocket-id.nix
    ./10-infrastructure/dns-automation.nix

    # 20 — Services
    ./20-services/media/default.nix
    ./20-services/media/media-stack.nix
    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/paperless.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix
    ./20-services/apps/scrutiny.nix
    ./20-services/apps/filebrowser.nix
    ./20-services/apps/ai-agents.nix
    ./20-services/apps/home-assistant.nix

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










/**
 * ---
 * technical_integrity:
 *   checksum: sha256:cd3caa41166057fd3126ffdd821985190f9aa824f3dba82d1ac6911b1985ef0a
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
