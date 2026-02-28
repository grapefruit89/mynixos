/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Adguardhome
 * TRACE-ID:     NIXH-INF-012
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:4487f3b9687d61b1264629a4ab70977cfb35256ce6ef268f0490e10dbab9962f
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
