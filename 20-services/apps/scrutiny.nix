/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-020
 *   title: "Scrutiny (SRE Hardened)"
 *   layer: 20
 * summary: Hard drive S.M.A.R.T monitoring with automated collection.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/scrutiny.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.scrutiny;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 SCRUTINY EXHAUSTION
  services.scrutiny = {
    enable = true;
    
    # ── DEKLARATIVE CONFIG ─────────────────────────────────────────────────
    settings = {
      web.listen.port = port;
      web.listen.host = "127.0.0.1";
      
      # SRE: Performance & Database
      log.level = "INFO";
    };

    # Nutzt InfluxDB für Trends (Standardmäßig aktiviert)
    influxdb.enable = true;
    
    # 🕵️ COLLECTOR (Automatischer Scan der Disks)
    collector = {
      enable = true;
      schedule = "daily";
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."scrutiny.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.scrutiny.serviceConfig = {
    # Aus nixpkgs übernommen: Isolation via DynamicUser
    DynamicUser = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # OOM-Schutz
    OOMScoreAdjust = 800;
  };

  # 🛡️ SMARTD Integration
  services.smartd.enable = true;
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
