/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-009
 *   title: "Homepage Dashboard"
 *   layer: 10
 * summary: Highly customizable application dashboard, fully declarative.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/homepage-dashboard.nix
 * ---
 */
{ config, pkgs, lib, ... }:
let
  dnsMap = import ./dns-map.nix;
  host = dnsMap.dnsMapping.dashboard or "nixhome.${dnsMap.baseDomain}";
in
{
  # 🚀 HOMEPAGE EXHAUSTION
  services.homepage-dashboard = {
    enable = true;
    
    # 🔐 SECRETS
    environmentFile = config.my.secrets.files.sharedEnv;

    # 📊 WIDGETS (SRE Monitoring)
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
          uptime = true;
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    # 🛠️ SERVICES (Deklarativ via Nix)
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
          { "OliveTin" = { icon = "olivetin.png"; href = "https://${dnsMap.dnsMapping.olivetin or "olivetin.m7c5.de"}"; }; }
          { "Pocket-ID" = { icon = "pocket-id.png"; href = "https://${dnsMap.dnsMapping.auth}"; }; }
          { "Netdata" = { icon = "netdata.png"; href = "https://netdata.${config.my.configs.identity.domain}"; }; }
          { "AdGuard" = { icon = "adguard-home.png"; href = "https://${dnsMap.dnsMapping.adguard or "adguard.m7c5.de"}"; }; }
        ];
      }
    ];

    settings = {
      title = "nixhome dashboard";
      # SRE: Performance & Privacy
      layout = {
        Media = { style = "grid"; columns = 3; };
        Tools = { style = "grid"; columns = 3; };
        Infrastructure = { style = "grid"; columns = 2; };
      };
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      # Tailscale darf ohne SSO drauf (Admin-Convenience)
      @tailscale remote_ip 100.64.0.0/10
      handle @tailscale {
        reverse_proxy 127.0.0.1:8082
      }

      # Externer Zugriff via Pocket-ID geschützt
      import sso_auth
      reverse_proxy 127.0.0.1:8082
    '';
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
