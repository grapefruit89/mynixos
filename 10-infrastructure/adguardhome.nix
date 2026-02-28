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
{ config, ... }:
let
  lanIP = config.my.configs.server.lanIP;
  tailscaleIP = config.my.configs.server.tailscaleIP;
  dnsDoH = config.my.configs.network.dnsDoH;
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
in
{
  # 🚀 ADGUARDHOME EXHAUSTION
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = config.my.ports.adguard;
    openFirewall = false;

    # VOLL-DEKLARATIVE EINSTELLUNGEN
    settings = {
      http.address = "0.0.0.0:${toString config.my.ports.adguard}";
      dns = {
        bind_hosts = [ "127.0.0.1" lanIP tailscaleIP ];
        upstream_dns = dnsDoH;
        bootstrap_dns = dnsBootstrap;
        cache_size = 4194304; # 4MB Cache
        cache_ttl_min = 600;
        filtering_enabled = true;
        filters_update_interval = 24;
      };
      filtering = {
        protection_enabled = true;
        safe_search = {
          enabled = true;
          google = true;
          bing = true;
        };
      };
      statistics = {
        enabled = true;
        interval = 1; # 1 Tag
      };
    };
  };
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:2cbcff62b586a9b2bb7147d95d27760b2a7b4ccabd57cdb7d7e8172113a32758
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
