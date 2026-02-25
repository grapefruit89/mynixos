{ config, ... }:
{
  # source: my.ports.adguard + services.adguardhome.settings
  # sink:   services.adguardhome + firewall extraInputRules (DNS LAN/Tailscale only)
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = config.my.ports.adguard;
    openFirewall = false;

    # Declarative upstream/bootstrap resolvers for stable DNS forwarding.
    settings = {
      dns = {
        # Avoid conflict with systemd-resolved (127.0.0.53/54:53) while keeping
        # AdGuard reachable for localhost, LAN and Tailscale clients.
        bind_hosts = [
          "127.0.0.1"
          "192.168.2.73"
          "100.113.29.82"
        ];
        # source-id: CFG.network.dnsDoH
        upstream_dns = config.my.configs.network.dnsDoH;
        # source-id: CFG.network.dnsBootstrap
        bootstrap_dns = config.my.configs.network.dnsBootstrap;
      };
    };
  };
}
