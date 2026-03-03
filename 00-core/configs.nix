{ lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten (Aviation-Grade)
  nms = {
    id = "NIXH-00-CORE-006";
    title = "Configs (SRE Master Source)";
    description = "Central source of truth for global identity, hardware toggles and SRE quotas.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "ssot/master" "sre/quotas" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  imports = [ ../10-infrastructure/vpn-live-config.nix ];

  options.my.meta.configs = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for configs module";
  };

  options.my.configs = {
    # ── BASTELMODUS ──────────────────────────────────────────────────────────
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Master switch for insecure debug mode.";
    };

    # ── IDENTITY ───────────────────────────────────────────────────────────
    identity = {
      host = lib.mkOption { type = lib.types.str; default = "q958"; }; # 🛰️ Hostname
      domain = lib.mkOption { type = lib.types.str; default = "m7c5.de"; };
      subdomain = lib.mkOption { type = lib.types.str; default = "nix"; }; # 🛡️ Sicherheits-Prefix
      email = lib.mkOption { type = lib.types.str; default = "moritzbaumeister@gmail.com"; };
      user = lib.mkOption { type = lib.types.str; default = "moritz"; };
    };

    # ── SERVER ──────────────────────────────────────────────────────────────
    server = {
      lanIP = lib.mkOption {
        type = lib.types.str;
        default = "192.168.2.73";
        description = "Lokale IP des Servers im Heimnetz.";
      };
      tailscaleIP = lib.mkOption {
        type = lib.types.str;
        default = "100.113.29.82";
        description = "Tailscale IP des Servers (100.x.y.z).";
      };
    };

    # ── NETWORK ────────────────────────────────────────────────────────────
    network = {
      lanCidrs = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [ "192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12" ];
        description = "RFC-1918 Subnetze.";
      };
      tailnetCidrs = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [ "100.64.0.0/10" ];
        description = "Tailscale CGNAT-Subnetz.";
      };
      dnsDoH = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        description = "DNS-over-HTTPS Upstream-Server für AdGuard Home.";
      };
      dnsBootstrap = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [ "9.9.9.9" "1.1.1.1" ];
        description = "Bootstrap-DNS für DoH-Auflösung.";
      };
      dnsFallback = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [ "9.9.9.9" "1.1.1.1" ];
        description = "Fallback-DNS.";
      };
    };

    # ── VPN ─────────────────────────────────────────────────────────────────
    vpn.privado = {
      publicKey = lib.mkOption { type = lib.types.str; default = ""; };
      endpoint  = lib.mkOption { type = lib.types.str; default = ""; };
      address   = lib.mkOption { type = lib.types.str; default = ""; };
      dns = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [];
        description = "DNS-Server im VPN-Namespace.";
      };
    };

    # ── HARDWARE ────────────────────────────────────────────────────────────
    hardware = {
      cpuType = lib.mkOption {
        type    = lib.types.enum [ "intel" "amd" "arm" ];
        default = "intel";
        description = "CPU-Typ für Microcode-Updates.";
      };
      intelGpu = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "Aktiviert Intel GPU-Beschleunigung (QSV/OpenCL).";
      };
      nvidiaGpu = lib.mkOption {
        type    = lib.types.bool;
        default = false;
        description = "Aktiviert NVIDIA GPU-Support.";
      };
      zigbeeStickIP = lib.mkOption {
        type    = lib.types.str;
        default = "192.168.2.46";
        description = "IP des SLZB-06 Zigbee Koordinators.";
      };
      ramGB = lib.mkOption {
        type    = lib.types.int;
        default = 16;
        description = "RAM in GB.";
      };
    };

    # ── LOCALES ────────────────────────────────────────────────────────────
    locale = {
      timezone = lib.mkOption { type = lib.types.str; default = "Europe/Berlin"; };
      default = lib.mkOption { type = lib.types.str; default = "de_DE.UTF-8"; };
      ocrLanguage = lib.mkOption { type = lib.types.str; default = "deu+eng"; };
    };

    # ── HARDWARE QUOTAS (SSoT for Resource Guarding) ──────────────────────
    resourceLimits = {
      maxAppRamMB = lib.mkOption { type = lib.types.int; default = 2048; };
      maxDatabaseRamMB = lib.mkOption { type = lib.types.int; default = 512; };
      maxMediaRamMB = lib.mkOption { type = lib.types.int; default = 1536; };
    };

    # ── GLOBAL PATHS (Nixarr Standard) ────────────────────────────────────
    paths = {
      storagePool = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; };
      mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/media"; };
      stateDir = lib.mkOption { type = lib.types.str; default = "/data/state"; };
    };
  };

  # ── ALARMS & SAFETY ──────────────────────────────────────────────────────
  config.systemd.services.bastelmodus-alarm = lib.mkIf config.my.configs.bastelmodus {
    script = ''
      wall "⚠️ BASTELMODUS AKTIV: Firewall AUS. Sudo PASSWORDLESS."
    '';
  };
}
