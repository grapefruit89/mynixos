{ config, pkgs, ... }:
{
  # Dieses Modul aktiviert ausgewählte Dienste.
  # Die detaillierte Konfiguration jedes Dienstes bleibt in seinem jeweiligen Modul.

  services.audiobookshelf.enable = true;
  services.jellyfin.enable = true;
  services.vaultwarden.enable = true;
  services.homepage.enable = true;
}
