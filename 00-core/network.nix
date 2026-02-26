# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Modernes Networking (systemd-networkd + Avahi / mDNS + BBR)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.systemd-networkd;
  host = config.my.configs.identity.host;
in
{
  config = lib.mkIf cfg.enable {
    # ── NETWORKD ─────────────────────────────────────────────────────────────
    networking.useNetworkd = true;
    networking.useDHCP = false;

    systemd.network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = "en*";
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "yes";
      };
    };

    # ── AVAHI (mDNS) ──────────────────────────────────────────────────────────
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # ── PERFORMANCE (TCP BBR & Buffers) ──────────────────────────────────────
    # Optimierung für Jellyfin Streaming und High-Speed Transfers
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      
      # Buffer-Größen auf 32MB max erhöhen (sink: streaming performance)
      "net.core.rmem_max" = 33554432;
      "net.core.wmem_max" = 33554432;
      "net.ipv4.tcp_rmem" = "4096 87380 33554432";
      "net.ipv4.tcp_wmem" = "4096 65536 33554432";
      
      # Backlog-Optimierung
      "net.core.netdev_max_backlog" = 5000;
    };

    services.resolved.enable = true;
    networking.networkmanager.enable = lib.mkForce false;
  };
}
