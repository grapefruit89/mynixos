/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-006
 *   title: "Configs"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ lib, config, ... }:
{
  imports = [ ../10-infrastructure/vpn-live-config.nix ];

  # ── BASTELMODUS ──────────────────────────────────────────────────────────
  options.my.configs.bastelmodus = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Aktiviert den Bastelmodus: Firewall aus, passwortloses Sudo, keine Security-Assertions.
      WARNUNG: Nur für Debugging! Automatische Deaktivierung nach 24h empfohlen.
    '';
  };

  # ── BASTELMODUS ALARM (CONFIG) ───────────────────────────────────────────
  config.systemd.timers.bastelmodus-alarm.wantedBy = lib.mkIf config.my.configs.bastelmodus [ "timers.target" ];
  config.systemd.timers.bastelmodus-alarm.timerConfig.OnBootSec = lib.mkIf config.my.configs.bastelmodus "5min";
  config.systemd.timers.bastelmodus-alarm.timerConfig.OnUnitActiveSec = lib.mkIf config.my.configs.bastelmodus "1h";

  config.systemd.services.bastelmodus-alarm.description = lib.mkIf config.my.configs.bastelmodus "Bastelmodus-Alarm: System ist unsicher konfiguriert";
  config.systemd.services.bastelmodus-alarm.serviceConfig.Type = lib.mkIf config.my.configs.bastelmodus "oneshot";
  config.systemd.services.bastelmodus-alarm.script = lib.mkIf config.my.configs.bastelmodus ''
    logger -p auth.warning "⚠️ BASTELMODUS AKTIV: Firewall AUS. Sudo PASSWORDLESS."
    wall "⚠️ BASTELMODUS AKTIV: Firewall ist deaktiviert! sudo nixos-rebuild switch um zu sichern."
  '';

  # ── IDENTITY ─────────────────────────────────────────────────────────────
  options.my.configs.identity.domain = lib.mkOption {
    type = lib.types.str;
    default = "m7c5.de";
    description = "Primäre Domain des Homelab-Stacks.";
  };

  options.my.configs.identity.email = lib.mkOption {
    type = lib.types.str;
    default = "moritzbaumeister@gmail.com";
    description = "Admin/ACME Kontaktadresse.";
  };

  options.my.configs.identity.user = lib.mkOption {
    type = lib.types.str;
    default = "moritz";
    description = "Primärer Administrationsbenutzer.";
  };

  options.my.configs.identity.host = lib.mkOption {
    type = lib.types.str;
    default = "nixhome";
    description = "Hostname des Servers.";
  };

  # ── HARDWARE ─────────────────────────────────────────────────────────────
  options.my.configs.hardware.cpuType = lib.mkOption {
    type = lib.types.enum [ "intel" "amd" "none" ];
    default = "intel";
    description = "CPU-Hersteller für Optimierungen.";
  };

  options.my.configs.hardware.gpuType = lib.mkOption {
    type = lib.types.enum [ "intel" "nvidia" "amd" "none" ];
    default = "intel";
    description = "GPU-Hersteller für Hardware-Beschleunigung.";
  };

  options.my.configs.hardware.ramGB = lib.mkOption {
    type = lib.types.int;
    default = 16;
    description = "Installierter Arbeitsspeicher in GB.";
  };

  options.my.configs.hardware.intelGpu = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Aktiviert Intel GPU-Optimierungen (GuC/HuC, Treiber).";
  };

  options.my.configs.hardware.updateMicrocode = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Aktiviert CPU-Microcode-Updates.";
  };

  # ── NETWORK ──────────────────────────────────────────────────────────────
  options.my.configs.network.lanCidrs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
    description = "Private LAN-Netze (RFC1918) für interne Freigaben.";
  };

  options.my.configs.network.tailnetCidrs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "100.64.0.0/10" ];
    description = "Tailscale CGNAT-Bereich für Tailnet-Zugriffe.";
  };

  options.my.configs.network.dnsDoH = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "https://one.one.one.one/dns-query" "https://dns.quad9.net/dns-query" ];
    description = "Upstream DoH Resolver.";
  };

  options.my.configs.network.dnsBootstrap = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "1.1.1.1" "9.9.9.9" ];
    description = "Bootstrap DNS Server für DoH Auflösung.";
  };

  options.my.configs.network.dnsNamed = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "1.1.1.1" "9.9.9.9" ];
    description = "Standard DNS Resolver.";
  };

  options.my.configs.network.dnsFallback = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "1.1.1.1" "9.9.9.9" ];
    description = "Fallback DNS Resolver.";
  };

  options.my.configs.network.acmeResolvers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "1.1.1.1:53" "9.9.9.9:53" ];
    description = "DNS Resolver für ACME-DNS-Challenge.";
  };

  # ── SERVER & VPN ─────────────────────────────────────────────────────────
  options.my.configs.server.lanIP = lib.mkOption {
    type = lib.types.str;
    default = "192.168.2.73";
    description = "Primäre LAN-IP des Servers.";
  };

  options.my.configs.server.tailscaleIP = lib.mkOption {
    type = lib.types.str;
    default = "100.113.29.82";
    description = "Tailscale-IP des Servers.";
  };

  options.my.configs.vpn.privado.address = lib.mkOption {
    type = lib.types.str;
    default = "100.64.4.147/32";
    description = "WireGuard Interface-IP für Privado VPN.";
  };

  options.my.configs.vpn.privado.dns = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "198.18.0.1" "198.18.0.2" ];
    description = "DNS-Server des Privado VPN.";
  };

  options.my.configs.vpn.privado.endpoint = lib.mkOption {
    type = lib.types.str;
    default = "91.148.237.21:51820";
    description = "WireGuard Peer-Endpoint für Privado VPN.";
  };

  options.my.configs.vpn.privado.publicKey = lib.mkOption {
    type = lib.types.str;
    default = "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
    description = "WireGuard Peer-PublicKey des Privado-Servers.";
  };

  # ── ASSERTIONS ───────────────────────────────────────────────────────────
  config.assertions = [
    {
      assertion = config.my.configs.server.lanIP != "";
      message = "CFG.server.lanIP muss gesetzt sein (z.B. '192.168.2.73')";
    }
    {
      assertion = config.my.configs.server.tailscaleIP != "";
      message = "CFG.server.tailscaleIP muss gesetzt sein (z.B. '100.x.y.z')";
    }
  ];
}









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:0ac8df6d7d2c03f52a55b1deca0a69a1c73f77010ffee8d8e5a1d196a8f6bb67
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
