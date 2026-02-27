{ config, lib, ... }:
# Traefik Dynamic Rules: Mapping services to hostnames from dns-map.nix.
# source: /etc/nixos/10-infrastructure/traefik-dynamic.nix
let
  # Fallback if map doesn't exist yet
  dnsFile = ./dns-map.nix;
  dnsMap = if builtins.pathExists dnsFile then import dnsFile else { 
    dnsMapping = { 
      jellyfin = "jellyfin.m7c5.de";
      traefik = "traefik.m7c5.de";
      tautulli = "tautulli.m7c5.de";
      homeassistant = "homeassistant.m7c5.de";
    }; 
  };
in
{
  services.traefik.dynamicConfigOptions.http.routers = {
    jellyfin-router = {
      rule = "Host(`${dnsMap.dnsMapping.jellyfin}`)";
      service = "jellyfin";
      tls.certResolver = "cloudflare";
    };
  };
}
