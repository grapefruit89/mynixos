# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: de-config Modul

{ ... }:
{
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  networking.timeServers = [
    "0.de.pool.ntp.org"
    "1.de.pool.ntp.org"
    "2.de.pool.ntp.org"
    "3.de.pool.ntp.org"
  ];

  networking.nameservers = [
    "127.0.0.1"
    "1.1.1.1#one.one.one.one"
    "9.9.9.9#dns.quad9.net"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "opportunistic";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
  };
}
