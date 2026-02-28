/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Traefik Dynamic Rules
 * TRACE-ID:     NIXH-INF-016
 * PURPOSE:      Manuelle Definition dynamischer Routen für Traefik (z.B. Jellyfin).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [10-infra/dns-map.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, lib, ... }:
let
  dnsFile = ./dns-map.nix;
  dnsMap = if builtins.pathExists dnsFile then import dnsFile else { 
    dnsMapping = { 
      jellyfin = "jellyfin.m7c5.de";
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
