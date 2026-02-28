/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-001
 *   title: "Adguardhome"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
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
  # 🚀 ADGUARDHOME EXHAUSTION (v2.3 SRE Standard)
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1"; # FIX: Nur lokal, Caddy proxied
    port = port;
    openFirewall = false;

    settings = {
      http.address = "127.0.0.1:${toString port}";

      # ── DNS CORE ────────────────────────────────────────────────────────
      dns = {
        bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
        port = 53;
        upstream_dns = dnsDoH;
        bootstrap_dns = dnsBootstrap;
        fallback_dns = config.my.configs.network.dnsFallback;
        cache_size = 33554432; # NEU: 32MB Cache
        cache_ttl_min = 300;
        cache_ttl_max = 86400; # NEU: Max TTL 24h
        cache_optimistic = true; # NEU: Stale-While-Revalidate
        filtering_enabled = true;
        filters_update_interval = 24;
        # NEU: EDNS Client Subnet deaktivieren (Privacy)
        edns_cs_enabled = false;
        # NEU: DNSSEC Validierung
        dnssec_enabled = true;
        # NEU: Parallele Upstream-Abfragen
        all_servers = false; # Nur ersten Upstream nutzen
        fastest_addr = true; # NEU: Schnellste Antwort gewinnt
      };

      # ── QUERY LOG ────────────────────────────────────────────────────────
      querylog = {
        enabled = true;
        file_enabled = true;
        interval = "24h";
        size_memory = 1000;
        add_timestamps = true;
      };

      # ── STATISTIKEN ──────────────────────────────────────────────────────
      statistics = {
        enabled = true;
        interval = "168h"; # NEU: 7 Tage
      };

      # ── FILTERING ────────────────────────────────────────────────────────
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        safe_browsing = { enabled = true; };
        parental = { enabled = false; };
        safe_search = { enabled = false; };
      };

      # ── LOKALE DNS REWRITES (UI-Silo gebrochen!) ─────────────────────────
      rewrites = [
        { domain = "nixhome.local"; answer = lanIP; }
        { domain = "*.${domain}"; answer = lanIP; }
        { domain = "*.nix.${domain}"; answer = lanIP; }
        { domain = "auth.${domain}"; answer = lanIP; }
        { domain = "netdata.${domain}"; answer = lanIP; }
      ];

      # ── CLIENTS ──────────────────────────────────────────────────────────
      clients.persistent = [
        { ids = [ lanIP ]; name = "nixhome-server"; }
      ];

      # ── USER RULES (Whitelist) ────────────────────────────────────────────
      user_rules = [
        "@@||nixhome.local^"
        "@@||${domain}^"
      ];
    };
  };

  # Caddy-Proxy für AdGuard Admin-UI (via SSO geschützt)
  services.caddy.virtualHosts."dns.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # systemd Hardening (Extreme SRE)
  systemd.services.AdGuardHome.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    NoNewPrivileges = true;
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    ReadWritePaths = [ "/var/lib/AdGuardHome" ];
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallFilter = [ "@system-service" ];
    OOMScoreAdjust = -200; # DNS darf nicht sterben
  };
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:f7a35ad6fe0b7a6c992d5be57c0e53587ac44e56d3d720b76c149b6970c704ca
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
