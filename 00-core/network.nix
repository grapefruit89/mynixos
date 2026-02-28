/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Modern Networking Stack
 * TRACE-ID:     NIXH-CORE-013
 * PURPOSE:      systemd-networkd Konfiguration, Avahi (mDNS) & TCP BBR Optimierung.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

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
        # Der Notfall-Anker (Immer erreichbar, auch ohne Router/DHCP)
        address = [ "10.254.0.1/24" ];
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
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      
      "net.core.rmem_max" = 33554432;
      "net.core.wmem_max" = 33554432;
      "net.ipv4.tcp_rmem" = "4096 87380 33554432";
      "net.ipv4.tcp_wmem" = "4096 65536 33554432";
      "net.core.netdev_max_backlog" = 5000;
    };

    services.resolved.enable = true;
    networking.networkmanager.enable = lib.mkForce false;
  };
}
