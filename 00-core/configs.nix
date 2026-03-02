/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-006
 *   title: "Configs (SRE Master Source)"
 *   layer: 00
 * summary: Central source of truth for global identity, hardware toggles and SRE quotas.
 * ---
 */
{ lib, config, ... }:
{
  imports = [ ../10-infrastructure/vpn-live-config.nix ];

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

    # ── LOCALES ────────────────────────────────────────────────────────────
    locale = {
      timezone = lib.mkOption { type = lib.types.str; default = "Europe/Berlin"; };
      default = lib.mkOption { type = lib.types.str; default = "de_DE.UTF-8"; };
      ocrLanguage = lib.mkOption { type = lib.types.str; default = "deu+eng"; };
    };

    # ── HARDWARE QUOTAS (SSoT for Resource Guarding) ──────────────────────
    # Diese Werte werden von Layer 10/20 Modulen für MemoryMax genutzt.
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
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
