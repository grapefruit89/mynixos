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
        
        # 🚀 Ultra Performance Tuning (NixOS 25.11 / 16GB RAM)
        cache_size = 67108864; # 64MB Cache (Verdoppelt für 16GB RAM)
        cache_ttl_min = 600;   # 10 Minuten Minimum (Reduziert Upstream Last)
        cache_ttl_max = 86400; # 24 Stunden Maximum
        cache_optimistic = true;
        fastest_addr = true;
        
        # Security & Privacy
        edns_cs_enabled = false;
        dnssec_enabled = true;
        anonymize_client_ip = true; # SRE: Privacy First
      };

      # ── EXPERT BLOCKLISTS (Single Source of Truth) ────────────────────────
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

  # ── SRE SANDBOXING (Aviation Grade) ──────────────────────────────────────
  systemd.services.adguardhome.serviceConfig = { # SSoT: Korrekter Service Name
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    ReadWritePaths = [ "/var/lib/adguardhome" ]; # SSoT: Lowercase Pfad prüfen
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    MemoryDenyWriteExecute = true; # SRE Hardening
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    OOMScoreAdjust = -200;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
