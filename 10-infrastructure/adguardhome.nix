{ ... }:
{
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = false;

    # Declarative upstream/bootstrap resolvers for stable DNS forwarding.
    settings = {
      dns = {
        upstream_dns = [
          "https://one.one.one.one/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
      };
    };
  };
}
