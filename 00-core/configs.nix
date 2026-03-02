/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-006
 *   title: "Configs (SRE Master Source)"
 *   layer: 00
 * summary: Central source of truth for global identity and hardware toggles with traceability.
 * ---
 */
{ lib, config, ... }:
{
  imports = [ ../10-infrastructure/vpn-live-config.nix ];

  # ── BASTELMODUS ──────────────────────────────────────────────────────────
  # source-id: CFG.identity.bastelmodus
  options.my.configs.bastelmodus = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Master switch for insecure debug mode.";
  };

  # ── IDENTITY (Master Sources) ───────────────────────────────────────────
  # source-id: CFG.identity.domain
  options.my.configs.identity.domain = lib.mkOption {
    type = lib.types.str;
    default = "m7c5.de";
    description = "Primary domain for the homelab stack.";
  };

  # source-id: CFG.identity.email
  options.my.configs.identity.email = lib.mkOption {
    type = lib.types.str;
    default = "moritzbaumeister@gmail.com";
    description = "Admin contact for ACME and alerts.";
  };

  # source-id: CFG.identity.user
  options.my.configs.identity.user = lib.mkOption {
    type = lib.types.str;
    default = "moritz";
    description = "Primary administrative user.";
  };

  # ── LOCALES & TIME (Master Sources) ───────────────────────────────────
  # source-id: CFG.locale.timezone
  options.my.configs.locale.timezone = lib.mkOption {
    type = lib.types.str;
    default = "Europe/Berlin";
    description = "Global system timezone.";
  };

  # source-id: CFG.locale.default
  options.my.configs.locale.default = lib.mkOption {
    type = lib.types.str;
    default = "de_DE.UTF-8";
    description = "Global default system locale.";
  };

  # source-id: CFG.locale.ocrLanguage
  options.my.configs.locale.ocrLanguage = lib.mkOption {
    type = lib.types.str;
    default = "deu+eng";
    description = "Standard languages for OCR processing (e.g., Paperless).";
  };

  # ── HARDWARE (Master Sources) ───────────────────────────────────────────
  # source-id: CFG.hardware.ramGB
  options.my.configs.hardware.ramGB = lib.mkOption {
    type = lib.types.int;
    default = 16;
    description = "Installed RAM in GB.";
  };

  # source-id: CFG.hardware.intelGpu
  options.my.configs.hardware.intelGpu = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Intel GPU optimizations (UHD 630).";
  };

  # source-id: CFG.hardware.zigbeeStickIP
  options.my.configs.hardware.zigbeeStickIP = lib.mkOption {
    type = lib.types.str;
    default = "192.168.2.200"; 
    description = "IP address of the SLZB-06 Ethernet Zigbee stick.";
  };

  # ── NETWORK (Master Sources) ────────────────────────────────────────────
  # source-id: CFG.network.lanCidrs
  options.my.configs.network.lanCidrs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
    description = "Trusted local networks (RFC1918).";
  };

  # source-id: CFG.network.tailnetCidrs
  options.my.configs.network.tailnetCidrs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "100.64.0.0/10" ];
    description = "Tailscale CGNAT range.";
  };

  # source-id: CFG.server.lanIP
  options.my.configs.server.lanIP = lib.mkOption {
    type = lib.types.str;
    default = "192.168.2.73";
    description = "Server's primary LAN IP.";
  };

  # ── ALARMS & SAFETY ──────────────────────────────────────────────────────
  config.systemd.services.bastelmodus-alarm = lib.mkIf config.my.configs.bastelmodus {
    script = ''
      wall "⚠️ BASTELMODUS AKTIV: Firewall AUS. Sudo PASSWORDLESS."
    '';
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
