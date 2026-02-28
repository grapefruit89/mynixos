/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        AdGuard Home DNS
 * TRACE-ID:     NIXH-INF-017
 * PURPOSE:      Lokaler DNS-Resolver mit Werbeblocker (LAN + Tailscale).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
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
