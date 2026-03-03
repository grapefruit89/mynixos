{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-GTW-001";
    title = "AdGuard Home (SRE Optimized)";
    description = "Declarative DNS filter with optimized cache, strict sandboxing and expert blocklists.";
    layer = 10;
    nixpkgs.category = "servers/dns";
    capabilities = [ "dns/filtering" "network/security" "privacy/anonymization" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  lanIP = config.my.configs.server.lanIP;
  tailscaleIP = config.my.configs.server.tailscaleIP;
  dnsDoH = config.my.configs.network.dnsDoH;
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.adguard;
in
{
  options.my.meta.adguardhome = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for adguardhome module";
  };


  config = lib.mkIf config.my.services.adguardhome.enable {
    services.adguardhome = {
      enable = true;
      host = "127.0.0.1";
      port = port;
      openFirewall = false;
      settings = {
        dns = {
          bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
          port = 53;
          upstream_dns = dnsDoH;
          bootstrap_dns = dnsBootstrap;
          fallback_dns = config.my.configs.network.dnsFallback;
          cache_size = 33554432;
          cache_ttl_min = 300;
          cache_ttl_max = 86400;
          cache_optimistic = true;
          fastest_addr = true;
          dnssec_enabled = true;
          anonymize_client_ip = true;
        };
        filtering = { protection_enabled = true; filtering_enabled = true; };
        filters = [
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard Base"; }
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; name = "AdGuard Tracking"; }
          { enabled = true; url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"; name = "Steven Black"; }
          { enabled = true; url = "https://small.oisd.nl/"; name = "OISD Small"; }
        ];
        rewrites = [ { domain = "nixhome.local"; answer = lanIP; } { domain = "*.${domain}"; answer = lanIP; } { domain = "auth.${domain}"; answer = lanIP; } ];
      };
    };

    services.caddy.virtualHosts."dns.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.adguardhome.serviceConfig = {
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      ReadWritePaths = [ "/var/lib/AdGuardHome" ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      OOMScoreAdjust = -200;
    };
  };
}
