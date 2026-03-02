/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-001
 *   title: "AdGuard Home (SRE Optimized)"
 *   layer: 10
 * summary: Declarative DNS filter with optimized cache and strict sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/adguardhome.nix
 * ---
 */
{ config, lib, ... }:
let
  lanIP = config.my.configs.server.lanIP;
  tailscaleIP = config.my.configs.server.tailscaleIP;
  dnsDoH = config.my.configs.network.dnsDoH;
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.adguard;
in
{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = port;
    openFirewall = false;

    # ── DEKLARATIVE EINSTELLUNGEN (Single Source of Truth) ──────────────────
    settings = {
      http.address = "127.0.0.1:${toString port}";

      dns = {
        bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
        port = 53;
        upstream_dns = dnsDoH;
        bootstrap_dns = dnsBootstrap;
        fallback_dns = config.my.configs.network.dnsFallback;
        
        # Performance Tuning
        cache_size = 33554432;   # 32MB Cache
        cache_ttl_min = 300;
        cache_ttl_max = 86400;   # Max TTL 24h
        cache_optimistic = true; # SRE: Stale-While-Revalidate
        fastest_addr = true;     # Nutzt den schnellsten Upstream
        
        # Privacy & Security
        edns_cs_enabled = false;
        dnssec_enabled = true;
      };

      # ── LOKALE DNS REWRITES ──────────────────────────────────────────────
      rewrites = [
        { domain = "nixhome.local"; answer = lanIP; }
        { domain = "*.${domain}"; answer = lanIP; }
        { domain = "auth.${domain}"; answer = lanIP; }
      ];

      statistics = {
        enabled = true;
        interval = "168h"; # 7 Tage Historie
      };
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."dns.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.AdGuardHome.serviceConfig = {
    # Vollständige Isolation vom restlichen System
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    
    # DNS-spezifische Privilegien
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    
    # Ressourcenschutz
    MemoryDenyWriteExecute = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    SystemCallFilter = [ "@system-service" ];
    OOMScoreAdjust = -200; # DNS ist ein kritischer Basis-Dienst
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
