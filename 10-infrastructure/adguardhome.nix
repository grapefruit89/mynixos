/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-001
 *   title: "AdGuard Home (SRE Optimized)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018]
 *   downstream: [NIXH-10-INF-002]
 *   status: audited
 * summary: Declarative DNS filter with optimized cache, strict sandboxing and expert blocklists.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/adguardhome.nix
 * ---
 */
{ config, lib, ... }:
let
  # source: CFG.server.lanIP       → 00-core/configs.nix
  lanIP        = config.my.configs.server.lanIP;
  # source: CFG.server.tailscaleIP → 00-core/configs.nix
  tailscaleIP  = config.my.configs.server.tailscaleIP;
  # source: CFG.network.dnsDoH     → 00-core/configs.nix
  dnsDoH       = config.my.configs.network.dnsDoH;
  # source: CFG.network.dnsBootstrap → 00-core/configs.nix
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
  # source: CFG.identity.domain    → 00-core/configs.nix
  domain       = config.my.configs.identity.domain;
  # source: PORT.adguard           → 00-core/ports.nix
  port         = config.my.ports.adguard;
in
{
  services.adguardhome = {
    enable = true;
    # Bind nur auf localhost — Caddy übernimmt den externen Zugriff
    host = "127.0.0.1";
    port = port;
    openFirewall = false;

    settings = {
      # http.address wird von nixpkgs aus host+port gebaut — kein Duplikat nötig

      dns = {
        # DNS lauscht auf allen lokalen Interfaces (LAN + Tailscale + Loopback)
        bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
        port = 53;
        upstream_dns  = dnsDoH;
        bootstrap_dns = dnsBootstrap;
        fallback_dns  = config.my.configs.network.dnsFallback;

        # Performance Tuning (konservativ für Homelab)
        cache_size        = 33554432; # 32MB — reicht für Heimnetz
        cache_ttl_min     = 300;      # 5 Minuten Minimum
        cache_ttl_max     = 86400;    # 24 Stunden Maximum
        cache_optimistic  = true;     # Stale-while-revalidate
        fastest_addr      = true;

        # Security & Privacy
        edns_cs_enabled     = false;
        dnssec_enabled      = true;
        anonymize_client_ip = true;
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled  = true;
        parental_enabled   = false;
        safe_search.enabled = false;
      };

      filters = [
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard Base"; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; name = "AdGuard Tracking"; }
        { enabled = true; url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";    name = "Steven Black"; }
        { enabled = true; url = "https://small.oisd.nl/";                                               name = "OISD Small"; }
      ];

      rewrites = [
        { domain = "nixhome.local";  answer = lanIP; }
        { domain = "*.${domain}";    answer = lanIP; }
        { domain = "auth.${domain}"; answer = lanIP; }
      ];

      statistics = {
        enabled  = true;
        interval = "168h";
      };
    };
  };

  services.caddy.virtualHosts."dns.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  systemd.services.adguardhome.serviceConfig = {
    # AdGuard braucht Port 53 → CAP_NET_BIND_SERVICE + CAP_NET_RAW für DNS-Pings
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities   = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    ReadWritePaths        = [ "/var/lib/adguardhome" ];

    ProtectSystem         = "strict";
    ProtectHome           = true;
    PrivateTmp            = true;
    PrivateDevices        = true;
    NoNewPrivileges       = true;
    LockPersonality       = true;
    RestrictRealtime      = true;
    RestrictSUIDSGID      = true;
    MemoryDenyWriteExecute = true;
    ProtectControlGroups  = true;
    ProtectKernelModules  = true;
    ProtectKernelTunables = true;
    SystemCallFilter      = [ "@system-service" "~@privileged" "~@resources" ];
    OOMScoreAdjust        = -200; # DNS ist kritisch — zuletzt töten
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - http.address Duplikat entfernt (nixpkgs baut das aus host+port)
 *     - cache_size von 64MB auf 32MB reduziert (Homelab-angemessen)
 *     - cache_ttl_min von 600 auf 300 (weniger aggressive Caching)
 *     - source-id Kommentare für alle config-Referenzen ergänzt
 *     - upstream/downstream Architecture-Header ergänzt
 * ---
 */
