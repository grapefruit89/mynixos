{ config, pkgs, lib, ... }:
let
  dnsMap = import ./dns-map.nix;
  vaultIP = "10.200.1.2";
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
          { "Traefik" = { icon = "traefik.png"; href = "https://${dnsMap.dnsMapping.traefik}"; }; }
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
      # Local Access (.local)
      @local host nixhome.local
      handle @local {
        reverse_proxy 127.0.0.1:8082
      }

      # TAILSCALE BYPASS (Wichtig!)
      @tailscale remote_ip 100.64.0.0/10
      handle @tailscale {
        reverse_proxy 127.0.0.1:8082
      }

      # PocketID-Auth für Public Access
      import sso_auth
      reverse_proxy 127.0.0.1:8082
    '';
  };
}
