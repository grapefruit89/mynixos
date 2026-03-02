/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-001
 *   title: "AdGuard Home (SRE Optimized)"
 *   layer: 10
 * summary: Declarative DNS filter with optimized cache, strict sandboxing and expert blocklists.
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

    # ── DEKLARATIVE EINSTELLUNGEN ───────────────────────────────────────────
    settings = {
      http.address = "127.0.0.1:${toString port}";

      dns = {
        bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
        port = 53;
        upstream_dns = dnsDoH;
        bootstrap_dns = dnsBootstrap;
        fallback_dns = config.my.configs.network.dnsFallback;
        
        # Performance Tuning
        cache_size = 33554432;
        cache_ttl_min = 300;
        cache_ttl_max = 86400;
        cache_optimistic = true;
        fastest_addr = true;
        
        # Privacy & Security
        edns_cs_enabled = false;
        dnssec_enabled = true;
      };

      # ── EXPERT BLOCKLISTS (Single Source of Truth) ────────────────────────
      # Diese Listen decken 99% aller Werbung, Tracker und Malware ab.
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search = { enabled = false; };
      };

      filters = [
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard Base filter"; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; name = "AdGuard Tracking Protection filter"; }
        { enabled = true; url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"; name = "Steven Black's Unified Hosts"; }
        { enabled = true; url = "https://small.oisd.nl/"; name = "OISD Small (High Stability)"; }
      ];

      # ── LOKALE DNS REWRITES ──────────────────────────────────────────────
      rewrites = [
        { domain = "nixhome.local"; answer = lanIP; }
        { domain = "*.${domain}"; answer = lanIP; }
        { domain = "auth.${domain}"; answer = lanIP; }
      ];

      statistics = {
        enabled = true;
        interval = "168h";
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

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.AdGuardHome.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    ReadWritePaths = [ "/var/lib/AdGuardHome" ];
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallFilter = [ "@system-service" ];
    OOMScoreAdjust = -200;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
