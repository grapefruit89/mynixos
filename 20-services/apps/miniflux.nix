/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-007
 *   title: "Miniflux (SRE Exhausted)"
 *   layer: 20
 * summary: Minimalist RSS reader with Wake-on-Access (Socket Activation).
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/miniflux.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.miniflux;
  domain = config.my.configs.identity.domain;
in
{
  services.miniflux = {
    enable = true;
    config = {
      # 🚀 Built-in Socket Activation support
      LISTEN_ADDR = "fd://3";
      WATCHDOG = "1";
      RUN_MIGRATIONS = "1";
    };
    createDatabaseLocally = true;
    adminCredentialsFile = config.sops.secrets.miniflux_admin_password.path;
  };

  # ── WAKE-ON-ACCESS (Socket Activation) ──────────────────────────────────
  systemd.sockets.miniflux = {
    description = "Miniflux Socket (Wake-on-Access)";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
  };

  # ── SRE SANDBOXING (Aviation Grade) ──────────────────────────────────────
  systemd.services.miniflux = {
    wantedBy = lib.mkForce [ ];
    requires = [ "miniflux.socket" ];
    after = [ "miniflux.socket" ];
    
    serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      OOMScoreAdjust = 500;
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
