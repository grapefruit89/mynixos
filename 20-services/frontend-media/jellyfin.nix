{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  # Jellyfin Service
  services.jellyfin = {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    user = "jellyfin";
    group = "jellyfin";
  };

  # QuickSync / Hardware Transcoding für Intel UHD 630
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    intel-compute-runtime
  ];
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  # Traefik Integration
  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`jellyfin.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "jellyfin";
    };
    services.jellyfin.loadBalancer.servers = [{
      url = "http://127.0.0.1:8096"; # Default port for Jellyfin
    }];
  };
}
