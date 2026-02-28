/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Network
 * TRACE-ID:     NIXH-CORE-017
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:4bf4a5af636f89fb3f71cadeb640cc2f2126b06f4197744444137040c0afaa73
 */

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.systemd-networkd;
in
{
  # ── NETWORKD ─────────────────────────────────────────────────────────────
  networking.useNetworkd = lib.mkIf cfg.enable true;
  networking.useDHCP = lib.mkIf cfg.enable false;
  networking.networkmanager.enable = lib.mkIf cfg.enable (lib.mkForce false);

  systemd.network.enable = lib.mkIf cfg.enable true;
  systemd.network.networks."10-lan".matchConfig.Name = "en*";
  systemd.network.networks."10-lan".networkConfig.DHCP = "yes";
  systemd.network.networks."10-lan".linkConfig.RequiredForOnline = "yes";
  systemd.network.networks."10-lan".address = [ "10.254.0.1/24" ];

  # ── AVAHI (mDNS) ──────────────────────────────────────────────────────────
  services.avahi.enable = lib.mkIf cfg.enable true;
  services.avahi.nssmdns4 = lib.mkIf cfg.enable true;
  services.avahi.publish.enable = lib.mkIf cfg.enable true;
  services.avahi.publish.addresses = lib.mkIf cfg.enable true;
  services.avahi.publish.workstation = lib.mkIf cfg.enable true;

  # ── DNS RESOLUTION ────────────────────────────────────────────────────────
  services.resolved.enable = lib.mkIf cfg.enable true;

  # ── PERFORMANCE (TCP BBR & Buffers) ──────────────────────────────────────
  boot.kernel.sysctl."net.core.default_qdisc" = lib.mkIf cfg.enable "fq";
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = lib.mkIf cfg.enable "bbr";
  boot.kernel.sysctl."net.core.rmem_max" = lib.mkIf cfg.enable 33554432;
  boot.kernel.sysctl."net.core.wmem_max" = lib.mkIf cfg.enable 33554432;
  boot.kernel.sysctl."net.ipv4.tcp_rmem" = lib.mkIf cfg.enable "4096 87380 33554432";
  boot.kernel.sysctl."net.ipv4.tcp_wmem" = lib.mkIf cfg.enable "4096 65536 33554432";
  boot.kernel.sysctl."net.core.netdev_max_backlog" = lib.mkIf cfg.enable 5000;
}
