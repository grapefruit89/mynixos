{ config, pkgs, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-009";
    title = "Homepage Dashboard";
    description = "Highly customizable application dashboard, fully declarative.";
    layer = 10;
    nixpkgs.category = "services/misc";
    capabilities = [ "web/dashboard" "observability/ui" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  dnsMap = import ./dns-map.nix;
  host = dnsMap.dnsMapping.dashboard or "nixhome.${dnsMap.baseDomain}";
in
{
  options.my.meta.homepage = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for homepage module";
  };


  config = lib.mkIf config.my.services.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      environmentFile = config.my.secrets.files.sharedEnv;
      widgets = [ { resources = { cpu = true; memory = true; disk = "/"; uptime = true; }; } { search = { provider = "duckduckgo"; target = "_blank"; }; } ];
      services = [
        { "Media" = [ { "Jellyfin" = { icon = "jellyfin.png"; href = "https://${dnsMap.dnsMapping.jellyfin}"; }; } { "Sonarr" = { icon = "sonarr.png"; href = "https://${dnsMap.dnsMapping.sonarr}"; }; } { "Radarr" = { icon = "radarr.png"; href = "https://${dnsMap.dnsMapping.radarr}"; }; } { "Prowlarr" = { icon = "prowlarr.png"; href = "https://${dnsMap.dnsMapping.prowlarr}"; }; } { "Readarr" = { icon = "readarr.png"; href = "https://${dnsMap.dnsMapping.readarr}"; }; } { "Audiobookshelf" = { icon = "audiobookshelf.png"; href = "https://${dnsMap.dnsMapping.audiobookshelf}"; }; } ]; }
        { "Tools" = [ { "Vaultwarden" = { icon = "vaultwarden.png"; href = "https://${dnsMap.dnsMapping.vault}"; }; } { "Paperless" = { icon = "paperless.png"; href = "https://${dnsMap.dnsMapping.paperless}"; }; } { "n8n" = { icon = "n8n.png"; href = "https://${dnsMap.dnsMapping.n8n}"; }; } { "Miniflux" = { icon = "miniflux.png"; href = "https://${dnsMap.dnsMapping.miniflux}"; }; } { "Monica" = { icon = "monica.png"; href = "https://${dnsMap.dnsMapping.monica}"; }; } ]; }
        { "Infrastructure" = [ { "OliveTin" = { icon = "olivetin.png"; href = "https://${dnsMap.dnsMapping.olivetin or "olivetin.m7c5.de"}"; }; } { "Pocket-ID" = { icon = "pocket-id.png"; href = "https://${dnsMap.dnsMapping.auth}"; }; } { "Netdata" = { icon = "netdata.png"; href = "https://netdata.${config.my.configs.identity.domain}"; }; } { "AdGuard" = { icon = "adguard-home.png"; href = "https://${dnsMap.dnsMapping.adguard or "adguard.m7c5.de"}"; }; } ]; }
      ];
      settings = { title = "nixhome dashboard"; layout = { Media = { style = "grid"; columns = 3; }; Tools = { style = "grid"; columns = 3; }; Infrastructure = { style = "grid"; columns = 2; }; }; };
    };
    services.caddy.virtualHosts."${host}" = {
      extraConfig = "@tailscale remote_ip 100.64.0.0/10\nhandle @tailscale { reverse_proxy 127.0.0.1:${toString config.my.ports.homepage} }\nimport sso_auth\nreverse_proxy 127.0.0.1:${toString config.my.ports.homepage}";
    };
  };
}
