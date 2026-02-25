# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: centralized shared values (single source of truth)
#   source-ids:
#     - CFG.identity.domain
#     - CFG.identity.email
#     - CFG.identity.user
#     - CFG.identity.host
#     - CFG.network.lanCidrs
#     - CFG.network.tailnetCidrs
#     - CFG.network.dnsNamed
#     - CFG.network.dnsFallback
#     - CFG.network.dnsDoH
#     - CFG.network.dnsBootstrap
#     - CFG.network.acmeResolvers

{ lib, config, ... }:
let
  cfg = config.my.configs;
in
{
  options.my.configs = {
    identity = {
      # source-id: CFG.identity.domain
      domain = lib.mkOption {
        type = lib.types.str;
        default = "m7c5.de";
        description = "Primary domain for homelab services.";
      };
      # source-id: CFG.identity.email
      email = lib.mkOption {
        type = lib.types.str;
        default = "moritzbaumeister@gmail.com";
        description = "Primary email for ACME and service notifications.";
      };
      # source-id: CFG.identity.user
      user = lib.mkOption {
        type = lib.types.str;
        default = "moritz";
        description = "Primary interactive user.";
      };
      # source-id: CFG.identity.host
      host = lib.mkOption {
        type = lib.types.str;
        default = "nixhome";
        description = "System hostname.";
      };
    };

    network = {
      # source-id: CFG.network.lanCidrs
      lanCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
        description = "Trusted RFC1918 ranges for LAN access rules.";
      };
      # source-id: CFG.network.tailnetCidrs
      tailnetCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "100.64.0.0/10" ];
        description = "Trusted Tailscale CGNAT ranges.";
      };
      # source-id: CFG.network.dnsNamed
      dnsNamed = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1#one.one.one.one"
          "9.9.9.9#dns.quad9.net"
        ];
        description = "Named DNS resolvers for systemd-resolved.";
      };
      # source-id: CFG.network.dnsFallback
      dnsFallback = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1#one.one.one.one"
          "1.0.0.1#one.one.one.one"
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
        description = "Fallback DNS resolvers for systemd-resolved.";
      };
      # source-id: CFG.network.dnsDoH
      dnsDoH = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "https://one.one.one.one/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        description = "DNS-over-HTTPS upstreams.";
      };
      # source-id: CFG.network.dnsBootstrap
      dnsBootstrap = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "9.9.9.9" ];
        description = "Bootstrap DNS servers.";
      };
      # source-id: CFG.network.acmeResolvers
      acmeResolvers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1:53" "8.8.8.8:53" ];
        description = "DNS resolvers for ACME DNS challenge.";
      };
    };
  };

  config = {
    # source-id: CFG.identity.user
    my.identity.user = lib.mkDefault cfg.identity.user;

    # source-id: CFG.identity.host
    my.identity.host = lib.mkDefault cfg.identity.host;
  };
}
