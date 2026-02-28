/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-016
 *   title: "Network"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
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
  systemd.network.config.networkConfig.ManageTemporaryAddress = true;

  systemd.network.networks."10-lan" = lib.mkIf cfg.enable {
    matchConfig.Name = "en*";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
      IPForward = "yes";
      IPMasquerade = "no";
      MulticastDNS = "yes";
      LLMNR = "yes";
    };
    linkConfig = {
      RequiredForOnline = "yes";
      Unmanaged = "no";
    };
    address = [ "10.254.0.1/24" ];
  };

  # ── DNS & RESOLVED EXHAUSTION ─────────────────────────────────────────────
  services.resolved = lib.mkIf cfg.enable {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ]; # Global resolver
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    extraConfig = ''
      DNSOverTLS=yes
      Cache=yes
      CacheMaxAgeSec=86400
    '';
  };

  # ── AVAHI (mDNS) ──────────────────────────────────────────────────────────
  services.avahi = lib.mkIf cfg.enable {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
    extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
  };

  # ── PERFORMANCE (TCP BBR & Buffers) ──────────────────────────────────────
  boot.kernel.sysctl = lib.mkIf cfg.enable {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.rmem_max" = 33554432;
    "net.core.wmem_max" = 33554432;
    "net.ipv4.tcp_rmem" = "4096 87380 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";
    "net.core.netdev_max_backlog" = 10000; # Erhöht für SRE-Last
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
  };
}







/**
 * ---
 * technical_integrity:
 *   checksum: sha256:bc485a28bed1b4aee1306b705fa2bc5cb5bfaa991ff7f16473c2a20e52aad432
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
