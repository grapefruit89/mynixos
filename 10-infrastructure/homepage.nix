{ config, pkgs, lib, ... }:
let
  dnsMap = import ./dns-map.nix;
  secrets = import ../.local-secrets.nix;
in
{
  services.homepage-dashboard = {
    enable = true;
    
    # Sinnvolle Gruppenstruktur statt einfacher Liste
    services = [
      {
        "Download & Media" = [
          {
            "Sonarr" = {
              icon = "sonarr.png";
              href = "https://${dnsMap.dnsMapping.sonarr}";
              description = "Serien-Management";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:8989";
                key = secrets.sonarr_api_key;
              };
            };
          }
          {
            "Radarr" = {
              icon = "radarr.png";
              href = "https://${dnsMap.dnsMapping.radarr}";
              description = "Film-Bibliothek";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                key = secrets.radarr_api_key;
              };
            };
          }
        ];
      }
      {
        "Infrastruktur" = [
          {
            "Traefik" = {
              icon = "traefik.png";
              href = "https://${dnsMap.dnsMapping.traefik}";
              description = "Reverse Proxy & SSL";
            };
          }
          {
            "Cloudflare" = {
              icon = "cloudflare.png";
              href = "https://dash.cloudflare.com";
              description = "DNS & Security";
            };
          }
        ];
      }
    ];

    # System-Widgets für das "Homelab-Feeling"
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "google";
          target = "_blank";
        };
      }
    ];

    settings = {
      title = "NixOS Homelab Central";
      background = "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=2070&auto=format&fit=crop";
      cardBlur = "md";
      theme = "dark";
    };
  };

  # Traefik Router: Erreichbar unter nixhome.m7c5.de
  services.traefik.dynamicConfigOptions.http.routers.homepage = {
    rule = "Host(\"nixhome.${dnsMap.baseDomain}\")";
    service = "homepage-dashboard";
    entryPoints = [ "websecure" ];
    tls.certResolver = "cloudflare";
  };
  
  services.traefik.dynamicConfigOptions.http.services.homepage-dashboard.loadBalancer.servers = [{
    url = "http://127.0.0.1:8082";
  }];
}
