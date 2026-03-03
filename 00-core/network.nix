{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-016";
    title = "Network (SRE Optimized)";
    description = "systemd-networkd configuration with DNS hardening and TCP BBR tuning.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = [ "network/systemd-networkd" "performance/tcp-bbr" "security/dns-over-tls" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.profiles.networking.systemd-networkd;
in
{
  options.my.meta.network = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for network module";
  };

  config = lib.mkIf cfg.enable {
    networking.useNetworkd = true;
    networking.useDHCP = false;
    networking.networkmanager.enable = lib.mkForce false;
    systemd.network.enable = true;
    systemd.network.config.networkConfig.IPv6PrivacyExtensions = "kernel";

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "en*";
      networkConfig = { DHCP = "yes"; IPv6AcceptRA = true; IPv4Forwarding = true; IPv6Forwarding = true; MulticastDNS = "yes"; LLMNR = "no"; };
      linkConfig = { RequiredForOnline = "yes"; };
    };

    services.resolved = {
      enable = true;
      dnssec = lib.mkForce "allow-downgrade";
      domains = [ "~." ]; 
      fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
      extraConfig = "DNSOverTLS=yes\nCache=yes\nCacheMaxAgeSec=86400";
    };

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = lib.mkForce "fq";
      "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr";
      "net.core.netdev_max_backlog" = lib.mkForce 10000;
      "net.ipv4.tcp_slow_start_after_idle" = lib.mkForce 0;
    };

    services.avahi = { enable = true; nssmdns4 = true; publish = { enable = true; addresses = true; workstation = true; }; };
  };
}
