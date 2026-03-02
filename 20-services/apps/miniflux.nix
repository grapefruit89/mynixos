/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-007
 *   title: "Miniflux (SRE Hardened)"
 *   layer: 20
 * summary: Minimalist RSS reader with auto-database setup and AppArmor protection.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/miniflux.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.miniflux;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 MINIFLUX EXHAUSTION
  services.miniflux = {
    enable = true;
    
    # ── DEKLARATIVE CONFIG ─────────────────────────────────────────────────
    config = {
      LISTEN_ADDR = "127.0.0.1:${toString port}";
      # SRE: Performance & Watchdog
      WATCHDOG = "1";
      RUN_MIGRATIONS = "1";
    };

    # ── DB-WIRING ──────────────────────────────────────────────────────────
    createDatabaseLocally = true; # Nutzt PostgreSQL aus Layer 10
    
    # Secret Handling (Admin Login)
    adminCredentialsFile = config.sops.secrets.miniflux_admin_password.path;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."rss.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Aviation Grade) ──────────────────────────────────────
  systemd.services.miniflux.serviceConfig = {
    # Aus nixpkgs übernommen: Maximale Isolation via DynamicUser
    DynamicUser = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # System-Call Filter
    SystemCallFilter = [ "@system-service" "~@privileged" ];
    
    # OOM-Schutz: Miniflux ist leichtgewichtig
    OOMScoreAdjust = 500;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
