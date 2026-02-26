# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: AdGuard Home DNS-Resolver (LAN + Tailscale)
#   dependsOn: ["00-core/configs.nix", "00-core/ports.nix"]

{ config, ... }:
let
  # source-id: CFG.server.lanIP
  # sink: bind_hosts LAN address
  lanIP = config.my.configs.server.lanIP;

  # source-id: CFG.server.tailscaleIP
  # sink: bind_hosts Tailscale address
  tailscaleIP = config.my.configs.server.tailscaleIP;

  # source-id: CFG.network.dnsDoH
  # sink: upstream DoH resolver list
  dnsDoH = config.my.configs.network.dnsDoH;

  # source-id: CFG.network.dnsBootstrap
  # sink: bootstrap DNS resolver list
  dnsBootstrap = config.my.configs.network.dnsBootstrap;
in
{
  # source-id: CFG.server.lanIP
  # source-id: CFG.server.tailscaleIP
  # sink: services.adguardhome listen/bind config
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
