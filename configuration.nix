{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./automation.nix

    ./00-core/system.nix
    ./00-core/de-config.nix
    ./00-core/users.nix
    ./00-core/ssh.nix
    ./00-core/firewall.nix
    ./00-core/aliases.nix

    ./10-infrastructure/tailscale.nix
    ./10-infrastructure/traefik.nix
    ./10-infrastructure/adguardhome.nix
    ./10-infrastructure/netdata.nix
    ./10-infrastructure/uptime-kuma.nix

    ./20-services/apps/audiobookshelf.nix
    ./20-services/apps/vaultwarden.nix
    ./20-services/apps/miniflux.nix
    ./20-services/apps/n8n.nix
    ./20-services/apps/scrutiny.nix
    ./20-services/apps/paperless.nix

    ./20-services/media/jellyfin.nix
    ./20-services/media/sonarr.nix
    ./20-services/media/radarr.nix
    ./20-services/media/prowlarr.nix
    ./20-services/media/sabnzbd.nix
  ];

  system.stateVersion = "25.11";
}
