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
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = config.my.ports.adguard;
    openFirewall = false;

    settings = {
      dns = {
        bind_hosts = [
          "127.0.0.1"
          lanIP
          tailscaleIP
        ];
        upstream_dns = dnsDoH;
        bootstrap_dns = dnsBootstrap;
      };
    };
  };
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:48a95faf4673d2cf8f35163cae3f20ccfcdc2dbca74fa20216fc23c46bbdc5df
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
