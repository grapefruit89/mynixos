/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-009
 *   title: "Homepage"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:cdc1dd204ea1e0a6c0222fe5e9803b65a666d3df6693eef86587cc6588e15fa2
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
