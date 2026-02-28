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
      { "Media" = [ { "Sonarr" = { icon = "sonarr.png"; href = "https://${dnsMap.dnsMapping.sonarr}"; }; } ]; }
      { "Infrastructure" = [ { "Traefik" = { icon = "traefik.png"; href = "https://${dnsMap.dnsMapping.traefik}"; }; } ]; }
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
