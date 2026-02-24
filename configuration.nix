{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./automation.nix

    ./00-core/system.nix
    ./00-core/host.nix
    ./00-core/00-REMOVE_BEFORE_FLIGHT.nix
    ./00-core/de-config.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./90-policy/security-assertions.nix
    ./00-core/aliases.nix

    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik.nix
    ./10-infrastructure/adguardhome.nix
    ./10-infrastructure/homepage.nix
    ./10-infrastructure/ddns-updater.nix
    ./10-infrastructure/valkey.nix
    ./10-infrastructure/wireguard-vpn.nix
    ./10-infrastructure/netdata.nix
    ./10-infrastructure/uptime-kuma.nix

    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix
    ./20-services/apps/scrutiny.nix
    ./20-services/apps/paperless.nix
    ./20-services/apps/readeck.nix

    ./20-services/media/default.nix
    ./20-services/media/media-stack.nix
  ];

  my.media.defaults.domain = "m7c5.de";

  # Critical SSH key: keep this in top-level config so it is never lost.
  users.users.moritz.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX"
  ];

  system.stateVersion = "25.11";
}
