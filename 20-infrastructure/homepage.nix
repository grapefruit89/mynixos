/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Homepage
 * TRACE-ID:     NIXH-INF-009
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:8291ce3a1f5db086563a76dc774c53f0d1b64d3b02459ad8b3469982b86be9ef
 */

{ config, pkgs, lib, ... }:
let
  dnsMap = import ./dns-map.nix;
  host = dnsMap.dnsMapping.dashboard or "nixhome.${dnsMap.baseDomain}";
in
{
  services.homepage-dashboard = {
    enable = true;
    environmentFile = config.my.secrets.files.sharedEnv;
    services = [
      {
        "Media" = [
          { "Jellyfin" = { icon = "jellyfin.png"; href = "https://${dnsMap.dnsMapping.jellyfin}"; }; }
          { "Sonarr" = { icon = "sonarr.png"; href = "https://${dnsMap.dnsMapping.sonarr}"; }; }
          { "Radarr" = { icon = "radarr.png"; href = "https://${dnsMap.dnsMapping.radarr}"; }; }
          { "Prowlarr" = { icon = "prowlarr.png"; href = "https://${dnsMap.dnsMapping.prowlarr}"; }; }
          { "Readarr" = { icon = "readarr.png"; href = "https://${dnsMap.dnsMapping.readarr}"; }; }
          { "Audiobookshelf" = { icon = "audiobookshelf.png"; href = "https://${dnsMap.dnsMapping.audiobookshelf}"; }; }
        ];
      }
      {
        "Tools" = [
          { "Vaultwarden" = { icon = "vaultwarden.png"; href = "https://${dnsMap.dnsMapping.vault}"; }; }
          { "Paperless" = { icon = "paperless.png"; href = "https://${dnsMap.dnsMapping.paperless}"; }; }
          { "n8n" = { icon = "n8n.png"; href = "https://${dnsMap.dnsMapping.n8n}"; }; }
          { "Miniflux" = { icon = "miniflux.png"; href = "https://${dnsMap.dnsMapping.miniflux}"; }; }
          { "Monica" = { icon = "monica.png"; href = "https://${dnsMap.dnsMapping.monica}"; }; }
        ];
      }
      {
        "Infrastructure" = [
          { "Pocket-ID" = { icon = "pocket-id.png"; href = "https://${dnsMap.dnsMapping.auth}"; }; }
          { "Netdata" = { icon = "netdata.png"; href = "https://netdata.${config.my.configs.identity.domain}"; }; }
          { "Scrutiny" = { icon = "scrutiny.png"; href = "https://${dnsMap.dnsMapping.scrutiny}"; }; }
        ];
      }
    ];
    settings.title = "nixhome dashboard";
  };

  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      @local host nixhome.local
      handle @local {
        reverse_proxy 127.0.0.1:8082
      }

      @tailscale remote_ip 100.64.0.0/10
      handle @tailscale {
        reverse_proxy 127.0.0.1:8082
      }

      import sso_auth
      reverse_proxy 127.0.0.1:8082
    '';
  };
}
