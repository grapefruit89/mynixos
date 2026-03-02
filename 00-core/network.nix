/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-016
 *   title: "Network (SRE Optimized)"
 *   layer: 00
 * summary: systemd-networkd config with DNS hardening and TCP BBR tuning.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/systemd-networkd.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.systemd-networkd;
in
{
  # ── NETWORKD EXHAUSTION ──────────────────────────────────────────────────
  networking.useNetworkd = lib.mkIf cfg.enable true;
  networking.useDHCP = lib.mkIf cfg.enable false;
  networking.networkmanager.enable = lib.mkIf cfg.enable (lib.mkForce false);

  systemd.network.enable = lib.mkIf cfg.enable true;
  
  # Globale networkd Einstellungen
  systemd.network.config.networkConfig.IPv6PrivacyExtensions = "kernel";

  systemd.network.networks."10-lan" = lib.mkIf cfg.enable {
    matchConfig.Name = "en*";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
      IPv4Forwarding = true;
      IPv6Forwarding = true;
      MulticastDNS = "yes"; 
      LLMNR = "no";
    };
    linkConfig = {
      RequiredForOnline = "yes";
    };
  };

  # ── DNS & RESOLVED EXHAUSTION ─────────────────────────────────────────────
  services.resolved = lib.mkIf cfg.enable {
    enable = true;
    dnssec = lib.mkForce "allow-downgrade";
    domains = [ "~." ]; 
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    extraConfig = ''
      DNSOverTLS=yes
      Cache=yes
      CacheMaxAgeSec=86400
    '';
  };

  # ── PERFORMANCE TUNING (TCP BBR) ──────────────────────────────────────────
  # 🚀 Aktiviert modernste Staukontrolle für stabilen Ingress/Egress.
  boot.kernel.sysctl = lib.mkIf cfg.enable {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.netdev_max_backlog" = 10000;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # ── AVAHI (mDNS) ──────────────────────────────────────────────────────────
  services.avahi = lib.mkIf cfg.enable {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
