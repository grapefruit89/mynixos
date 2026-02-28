/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-001
 *   title: "Adguardhome"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:b8b434f5aed34f5e6a8b3ff3f5c1ab98c1b13c9e453957366e1bf99db619e016
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
